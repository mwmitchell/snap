module Snap::Context
  
  class Base
    
    include Snap::RequestHelpers
    include Snap::ConfigHelpers
    include Snap::Context::Hooks
    
    attr_accessor :parent
    attr_reader :name, :path, :options, :block, :full_path
    attr_reader :response, :request
    
    # The matching action
    attr_reader :action
    
    %W(get post put delete head).each do |m|
      class_eval <<-EOF
        def #{m}(path='', options={}, &block)
          add_action :#{m}, path, options, &block
        end
      EOF
    end
    
    def initialize(path, options={}, parent=nil, &block)
      init(path, options, parent, &block)
    end
    
    def init(path, options={}, parent=nil, &block)
      @name=nil
      @path=URI.encode(path)
      if path.is_a?(Hash)
        @name,@path=path.keys.first, path.values.first
      elsif path.is_a?(Symbol)
        @name,@path=path,''
      end
      @options=options
      @parent=parent
      @block=block if block_given?
    end
    
    def load_script(name)
      instance_eval File.read(name) rescue raise "#{$!} - when loading #{name}"
    end
    
    def method_missing(m,*args,&block)
      parent.send(m,*args,&block)
    end
    
    def use(klass, *args)
      # response.write "USE children.size == #{children.size}"
      klass.root.parent=self
      children<<[klass, args] unless children.detect{|i|(i[0]==klass and i[1]==args)}
    end
    
    def context(path, options={}, &block)
      add_child path, options, &block
    end
    
    def actions
      @actions=[] unless @actions
      @actions
    end
    
    def add_action(request_method, path, options={}, &block)
      # response.write "actions.size == #{actions.size}"
      # remove existing action if it has the same request_method, path and options
      actions.delete_if{|a|(a.request_method==request_method and path==a.path and options==a.options)}
      actions << Snap::Action.new(self, request_method, path, options, &block)
    end
    
    def children
      @children = [] unless @children
      @children
    end
    
    #
    # TO DO: store children in hash, using add_child args as key - this will allow code reloading of blocks
    #
    def add_child(path, options={}, &block)
      # response.write "children.size == #{children.size}"
      # remove existing child if it has the same path and options
      children.delete_if{|c|(c.path==path && c.options==options)}
      children << self.class.new(path, options, self, &block)
    end
    
    def execute(request, response)
      begin
        halted_content = catch :halt do
          run_safely do
            @action=find_action(request, response)
            # could do something here with returned content from before filters...
            @action.execute_before_blocks(@action)
            # append action response to body...
            response.write @action.execute(request, response)
            # could do something here with returned content from after filters...
            @action.execute_after_blocks(@action)
          end
          nil
        end
        response.write halted_content if halted_content
      rescue
        if config.env == :production
          response.status=500
          response.body = ['Something has gone horribly wrong...']
        else
          raise $!
        end
      end
      response.finish
    end
    
    def run_safely
      if config.mutex
        mutex.synchronize { yield }
      else
        yield
      end
    end
    
    def mutex
      @@mutex ||= Mutex.new
    end
    
    def find_action(request, response, parent=nil)
      @full_path||=(parent ? [parent.full_path, path].join('/') : path).cleanup('/')
      @request=request
      @response=response
      pi=request.path_info.cleanup('/')
      instance_eval &@block if @block
      children.each do |child|
        if child.is_a?(Array)
        #  if a=child[0].root.find_action(request, response, child[0])
        #    a.context.app=child[0].new((@app||app_klass.new))
        #    return a
        #  end
        elsif a=child.find_action(request, response, parent)
          #child.parent=self
          return a
        end
      end
      actions.each do |a|
        if a.match?(request.request_method, pi)
          return a
        end
      end
      nil
    end
    
  end
  
end