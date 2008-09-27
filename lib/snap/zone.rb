module Snap::Zone
  
  autoload :Callbacks, 'snap/zone/callbacks'
  autoload :Action, 'snap/zone/action'
  autoload :Event, 'snap/zone/event'
  
  class Base
    
    include Snap::Context
    include Snap::Zone::Callbacks
    
    attr_accessor :parent
    attr_reader :full_name, :name, :path, :options, :block, :full_path
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
    
    def init(input_path, options={}, parent=nil, &block)
      @name, @path = self.class.resolve_name_and_path(input_path)
      @options=options
      @parent=parent
      @block=block if block_given?
      @full_name = @parent.nil? ? @name : [@parent.full_name, @name].reject{|v|v.to_s.empty?}.join('/')
    end
    
    def method_missing(m,*args,&block)
      parent.send(m,*args,&block) rescue "Couldn't find method \"#{m}\" in zone or parent zone(s)."
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
      actions << Snap::Zone::Action.new(self, request_method, path, options, &block)
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
            @action.execute
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
      pi=request.path_info
      instance_eval &@block if @block
      children.each do |child|
        c=child.find_action(request, response, self)
        return c if c
      end
      actions.each do |a|
        return a if a.match?(request.request_method, pi)
      end
      nil
    end
    
    #
    # Utility method that extracts a "name" and "path" from some arbitrary input:
    # {:id=>'path'} => [:id, 'path']
    # :default => [:default, '']
    # 'path' => [nil, 'path']
    #
    def self.resolve_name_and_path(input_path)
      name=nil
      if input_path.class == String
        # standard, id-less action
        # get 'admin' do
        # ...
        # end
        path = input_path
        # puts "String! name == #{name} and path == #{path}"
      elsif input_path.class == Hash
        # for identifying an action:
        # get :admin=>'admin' do
        # ...
        # end
        name, path = input_path.keys.first, input_path.values.first
        # puts "Hash! name == #{name} and path == #{path}"
      elsif input_path.class == Symbol
        # in case you want to identify an action, but not specify the blank path
        # get :home do
        # ...
        # end
        # puts "Symbol! name == #{name} and path == #{path}"
        name, path = input_path, ''
      else
        # puts "Something Else! @name == #{name} and @path == #{path}"
        path=input_path.to_s
      end
      [name, URI.encode(path.to_s)]
    end
    
  end
  
end