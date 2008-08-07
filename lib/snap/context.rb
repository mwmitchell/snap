module Snap::Context
  
  class Base
    
    include ActionMethods
    include Hooks
    include Snap::Loader
    
    attr_accessor :parent
    attr_reader :name, :path, :options, :block, :full_path
    attr_reader :response, :request
    
    # The matching action
    attr_reader :action
    
    def initialize(path, options={}, parent=nil, &block)
      init(path, options, parent, &block)
    end
    
    def init(path, options={}, parent=nil, &block)
      @name=nil
      @path=path
      if path.is_a?(Hash)
        @name,@path=path.keys.first, path.values.first
      elsif path.is_a?(Symbol)
        @name,@path=path,''
      end
      @options=options
      @parent=parent
      @block=block if block_given?
    end
    
    def method_missing(m,*args,&block)
      parent.send(m,*args,&block)
    end
    
    def use(klass, *args)
      # response.write "USE children.size == #{children.size}"
      klass.root.parent=self
      children<<[klass, args] unless children.detect{|i|(i[0]==klass and i[1]==args)}
    end
    
    def map(path, options={}, &block)
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
      catch :halt do
        @action=find_action(request, response)
        if @action
          @action.execute
        end
      end
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