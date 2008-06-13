require 'rubygems'
require 'rack'

$:.unshift File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)

module Rack
  class Response
    include Enumerable
  end
end

module Snap
  
  VERSION='0.3.1'
  
  class Request < Rack::Request
    def method_sym
      request_method.to_s.downcase.to_sym
    end
    def path_info_slices
      ['/'] + path_info.to_s.gsub(/\/+/, '/').sub(/^\/|\/$/, '').split('/')
    end
  end
  
  module Context

    class Action
      
      #
      # The main context class needs to be able to resfresh this when reloading this action instance
      #
      attr_accessor :context
      
      attr :method
      attr :options
      attr :block
      
      def initialize(method, context, options={}, &block)
        @context=context
        @method=method
        @options=options
        @block=block
      end
      
      def app; @context.app end
      def request; app.request end
      def params; request.params end
      
      def method_missing(m,*args,&block)
        app.send(m, *args, &block) if [:header, :headers, :response].include?(m)
      end
      
      def execute!
        instance_eval(&@block)
      end
      
    end

    #
    #
    #
    module InstanceMethods

      #
      # The main app class needs to be able to set this
      #
      attr_accessor :app

      #
      # attributes that are set by the "initialize" method
      #
      # can be a string, regexp, hash or symbol
      #  * string - the current path slice will be compared using ==
      #  * regexp - the current path slice will be compared using =~
      #  * hash - if the value matches, the current slice is assigned to the request.params using the key
      #    * the value can in-turn be any string, regexp, hash or symbol
      #  * symbol - can be used to match preset rules found in the +PATTERNS+ hash
      #    if the symbol is not found in +PATTERNS+, it's converted to a string and uses ==
      #
      attr :pattern
      # The parent context
      attr :parent
      # the options passed into +map+ method calls
      attr :options
      # optional module name to delegate logic for a given sub-path
      attr :delegate
      # the block that holds the executable context code
      attr :block
      
      def method_missing(m,*args,&block)
        @app.send(m, *args, &block) if [:header, :headers, :response].include?(m)
      end
      
      #
      # Create the HTTP action methods...
      #
      HTTP_METHODS=%W(get post put delete)
      HTTP_METHODS.each do |m|
        class_eval <<-EOF
          def #{m}(options={}, &block)
            if a=actions.detect {|a|a.method==:#{m}.to_sym and a.options==options}
              # refresh the app - this is needed because the root context is a "static" instance
              a.context=self
              return
            end
            actions << Action.new(:#{m}, self, options, &block)
          end
        EOF
      end
      
      #
      # "attributes" that are set after initialization
      #

      # returns the child contexts
      def children; @children||=[]; end
      # returns the value from the path slices that this context matched
      def value; @value||=nil; end
      # the base application instance
      def app; @app; end
      # returns instance of Rack::Request
      def request; app.request; end
      # shortcut for request.params
      def params; request.params; end
      # 
      def actions; @actions||=[] end
      #
      def before_blocks; @before_blocks||={} end
      #
      def after_blocks; @after_blocks||={} end

      def before(action=:all, &block)
        before_blocks[action]=block
      end

      def after(action=:all, &block)
        after_blocks[action]=block
      end

      #
      # Finds the action (get, post, put etc.) base on:
      # * the method
      # * the env/hash values
      #
      def find_action(method, env={})
        actions.each do |a|
          next if a.method != method
          return a if a.options.nil? or a.options.size==0
          a.options.each_pair do |k,v|
            k=k.to_s.upcase
            return a if env[k]==v or env[k]=~v
          end
        end
        nil
      end
      
      def execute_before_blocks(method)
        parent.execute_before_blocks(method) if parent
        bb=(@before_blocks[method] || @before_blocks[:all]) rescue nil
        instance_eval(&bb) if bb
      end
      
      def execute_after_blocks(method)
        parent.execute_after_blocks(method) if parent
        ab=(@after_blocks[method] || @after_blocks[:all]) rescue nil
        instance_eval(&ab) if ab
      end
      
      def execute_action(method, env={})
        action = find_action(request.method_sym, request.env)
        raise ErrorActionNotFound if action.nil?
        #execute_before_blocks(method)
        response.write action.execute!
        #execute_after_blocks(method)
      end
      
      PATTERNS={
        :digit=>/^\d+$/,
        :word=>/^\w+$/
      }

      #
      # Checks the pattern against the value
      # The pattern can be a:
      #   * string - uses == to compare
      #   * regexp - uses =~ to compare
      #   * symbol - first looks up value in PATTERNS; if found, uses the PATTERN value; if not, converts to string
      #   * hash - assigns the value to the key within the params array if matches; the value can be any of the above
      #
      # ==Examples
      #   match?('hello', 'hello') == true
      #   match?(/h/, 'hello') == true
      #   match?(:digit, 1) == true - does a successfull lookup in PATTERNS
      #   match?(:admin, 'admin') == true - non-succesfull PATTERNS lookup, convert to string
      #   match?(:id=>:digit, 1) == true - also sets params[:id]=1
      #   match?(:name=>:word, 'sam') == true - sets params[:name]='sam'
      #   match?(:topic=>/^authors$|^publishers$/, 'publishers') - true - sets params[:topic]='publishers'
      #
      def match?(pattern, value)
        ok = simple_match?(pattern, value)
        return ok if ok
        # if hash, use the value as the pattern and set the request param[key] to the value argument
        return (params[pattern.keys.first] = match?(pattern[pattern.keys.first], value)) if pattern.is_a?(Hash)
        # if symbol
        if pattern.is_a?(Symbol)
          # lookup the symbol in the PATTERNS hash
          return value if PATTERNS[pattern] and match?(PATTERNS[pattern], value)
          # There was no match, convert to string
          simple_match?(pattern.to_s, value)
        end
      end

      #
      # Non-nested comparisons using == or =~
      #
      def simple_match?(pattern, value)
        # if string, simple comparison
        return value if (pattern.is_a?(String) and value == pattern)
        # if regexp, regx comparison
        return value if (pattern.is_a?(Regexp) and value =~ pattern)
      end
      
      class ErrorContextNotFound < RuntimeError; end
      class ErrorActionNotFound < RuntimeError; end
      
      #
      # Recursively looks for matching context instances returning the last one that matches.
      #
      def resolve(slices)
        return unless match?(pattern, slices.first)
        @value=slices.shift
        catch :delegate do
          instance_eval(&@block) if @block
        end
        if delegate
          raise 'Only module based delegates are allowed' unless delegate.class==Module
          return delegate.delegate!(self, [@value]+slices)
        end
        return self if slices.size==0
        children.each do |child|
          if found=child.resolve(slices)
            return found
          end
        end
        raise ErrorContextNotFound
      end

      #
      # Shortcut for assigning a delegate
      #
      def delegate_to(handler)
        @delegate=handler
        throw :delegate
      end
      
      #
      # Compares the pattern and options on exsisting mapped children
      # Returns the first one that matches
      #
      def child_exists?(pattern, options)
        children.detect{|child|child.pattern==pattern and child.options==options}
      end

      #
      # The main method for creating child contexts
      #
      def map(pattern, options={}, delegate=nil, &block)
        if child=child_exists?(pattern, options)
          # refresh the app
          # this is required as the root context is a class based attribute
          # it doesn't get re-instantiated for every MyApp.new for example
          child.app=@app
          return child
        else
          children << Context::Base.new(pattern, options, delegate, self, &block)
          children.last.app=app
        end
      end

    end # end InstanceMethods

    #
    #
    #

    #
    # Used for handling areas of your application, within the context of some path.
    # For example, if you had a blog area of your site, you could off-load the logic
    # from the main app to a "delegate" and keep the main app clear of too much clutter.
    # It would actually be possible for your main app to do nothing but delegate.
    #
    module Delegate

      #
      # Shortcut for:
      #   extend Snap::Context::Delegate::ClassMethods
      #
      def self.included(base)
        base.extend ClassMethods
      end

      #
      # Snap::Context::Delegate::ClassMethods
      #
      module ClassMethods

        #
        # Bring in the standard context methods
        #
        include Context::InstanceMethods

        #
        # define the standard build method so the delegate can start creating the context tree
        #
        def build(options={}, &block)
          @options=options
          @block=block
        end

        #
        # Sets up this module as a delegate handler
        # delegating_for - Snap::Context::Base instance
        # slices - array of path fragments
        #
        def delegate!(delegating_for, slices)
          @app=delegating_for.app
          @parent=delegating_for.parent
          # Set the @pattern to the delegating_for's value so that when resolve is called, there will be a match
          @pattern=delegating_for.value
          # add this delegate to the delegating_for.parent.children
          delegating_for.parent.children.unshift self
          # find the matching context based on the slices
          return resolve(slices)
        end
      end

    end

    #
    # The base context class that gets instantiated for each "map" call
    #
    class Base

      include Context::InstanceMethods

      #
      #
      #
      def initialize(pattern, options={}, delegate=nil, parent=nil, &block)
        @pattern=pattern
        @options=options
        @delegate=delegate
        @block=block
        @parent=parent
      end

    end

  end

  #########

  module App

    #
    # Shortcut for:
    #   include Snap::App::InstanceMethods
    #   extend Snap::App::ClassMethods
    #
    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
    end

    #
    # The class methods; provides the main "build" method
    #
    module ClassMethods

      attr :root

      #
      # The initial build, class method
      #
      def build(options={}, &block)
        @root=Context::Base.new('/', options, nil, nil, &block)
      end

    end

    #
    # The interface for Rack to connect to using the +call+ method
    #
    module InstanceMethods
      
      def root; self.class.root end
      
      def request; @request end
      
      def response; @response; end
      
      #
      #
      #
      def header(name, value)
        response[name]=value
      end
      
      #
      #
      #
      def headers(hash)
        hash.each_pair {|k,v|header(k,v)}
      end
      
      #
      #
      #
      def call(rack_env)
        @request=Request.new(rack_env)
        @response=Rack::Response.new
        
        if root.nil?
          response.status=500
          response.body='Server Error'
          return response.finish
        end
        root.app=self
        
        begin
          context = root.resolve(request.path_info_slices)
        rescue Context::InstanceMethods::ErrorContextNotFound
          response.status=404
          response.body='Resource Not Found'
          return response.finish
        end
        
        begin
          context.execute_action(request.method_sym, request.env)
        rescue Context::InstanceMethods::ErrorActionNotFound
          response.status=500
          response.body='Server Error: No response with given request method'
        end
        response.finish
      end
      
    end
    
  end
  
end