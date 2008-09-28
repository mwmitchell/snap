module Snap::Zone
  
  autoload :Callbacks, 'snap/zone/callbacks'
  autoload :Action, 'snap/zone/action'
  autoload :Event, 'snap/zone/event'
  
  class Base
    
    include Snap::Context
    include Snap::Zone::Callbacks
    
    attr_accessor :parent
    attr_reader :full_key, :key, :route, :full_route, :options, :block
    attr_reader :response, :request
    
    # The matching action
    attr_reader :action
    
    %W(get post put delete head).each do |m|
      class_eval <<-EOF
        def #{m}(route='', options={}, &block)
          add_action :#{m}, route, options, &block
        end
      EOF
    end
    
    def initialize(route, options={}, parent=nil, &block)
      init(route, options, parent, &block)
    end
    
    def init(input, options={}, parent=nil, &block)
      @key, @route = self.class.resolve_key_and_route(input)
      @options=options
      @parent=parent
      @block=block if block_given?
      @full_key = @parent.nil? ? @key : [@parent.full_key, @key].reject{|v|v.to_s.empty?}.join('/')
    end
    
    def method_missing(m,*args,&block)
      parent.send(m,*args,&block) rescue "Couldn't find method \"#{m}\" in zone or parent zone(s)."
    end
    
    def map(input_route, options={}, &block)
      add_child input_route, options, &block
    end
    
    def actions
      @actions=[] unless @actions
      @actions
    end
    
    def add_action(request_method, input_route, options={}, &block)
      actions << Snap::Zone::Action.new(self, request_method, input_route, options, &block)
    end
    
    def children
      @children = [] unless @children
      @children
    end
    
    #
    # TO DO: store children in hash, using add_child args as key - this will allow code reloading of blocks
    #
    def add_child(input_route, options={}, &block)
      children << self.class.new(input_route, options, self, &block)
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
      @full_route||=(parent ? [parent.full_route, @route].join('/') : @route).cleanup('/')
      @request=request
      @response=response
      pi=request.path_info
      instance_eval &@block if @block
      children.each do |child|
        a=child.find_action(request, response, self)
        return a if a
      end
      actions.each do |a|
        return a if a.match?(request.request_method, pi)
      end
      nil
    end
    
    #
    # Utility method that extracts a "key" and "route" from some arbitrary input:
    # {:id=>'route'} => [:id, 'route']
    # :default => [:default, '']
    # 'route' => [nil, 'route']
    #
    def self.resolve_key_and_route(input)
      key=nil
      if input.class == String
        # standard, id-less action
        # get 'admin' do
        # ...
        # end
        route = input
        # puts "String! key == #{key} and route == #{route}"
      elsif input.class == Hash
        # for identifying an action:
        # get :admin=>'admin' do
        # ...
        # end
        key, route = input.keys.first, input.values.first
        # puts "Hash! key == #{key} and route == #{route}"
      elsif input.class == Symbol
        # in case you want to identify an action, but not specify the blank route
        # get :home do
        # ...
        # end
        # puts "Symbol! key == #{key} and route == #{route}"
        key, route = input, ''
      else
        # puts "Something Else! @key == #{key} and @route == #{route}"
        route=input.to_s
      end
      [key, URI.encode(route.to_s)]
    end
    
  end
  
end