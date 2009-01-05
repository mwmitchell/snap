#
# The Namespace::Base class is a container for actions and before/after filters
# It can also contain child Namespace::Base instances as well as a parent
# Its block is executed within its own scope, NOT the app
#   HINT: if you want to always execute some app code for a namespace/route, do it in a before/after filter!
module Snap::App::Namespace
  
  module CommonMethods
    
    attr_reader :route, :opts, :parent, :block, :app
    
    # This method gets called by the dispatcher and passes in an instance of the app class
    # ** the app class is the scope for all actions and before/after filters **
    def execute(app)
      @app=app
      instance_eval &@block
      children.each do |child|
        child.execute(app)
      end
    end
    
    #
    def use(app_klass)
      mixin app_klass.new
    end
    
    #
    def mixin(app_instance)
      app_instance.build(@app.request, @app.response)
      app_instance.namespaces.each do |ns|
        self.namespace(ns.route, ns.opts, &ns.block)
      end
      app_instance
    end
    
    def actions
      @actions||=[]
    end
    
    def children
      @children||=[]
    end
    
    def namespace(route, opts={}, &block)
      ns = Snap::App::Namespace::Base.new(route, opts, self, &block)
      self.children << ns
      self.app.namespaces << ns
    end
    
    %W(before after).each do |m|
      class_eval <<-EOF
        def #{m}s; @#{m}s ||= []; end
        def #{m}(opts={}, &blk)
          #{m}s << {:opts=>opts, :block=>blk}
        end
      EOF
    end
    
    %W(get post put delete head).each do |m|
      class_eval <<-EOF
        def #{m}(route='', opts={}, &blk)
          a = Snap::App::Action.new(self, :#{m}, route, opts, &blk)
          self.actions << a
          self.app.actions << a
        end
      EOF
    end
    
    def ancestors
      @parent ? [@parent] + @parent.ancestors : []
    end

    # gets all descendant actions
    def descendants
      children + children.map(&:children).flatten
    end

    # calculates the full route: all parent routes + this route
    def full_route
      @parent ? (ancestors.reverse + [self]).map(&:route).join('/').squeeze('/') : route
    end
    
    # returns the filter chain for :before or :after type filters
    # the :before ordering is top down to self
    # the :after ordering is self/bottom up to the root namespace
    def filters(type)
      case type
      when :before
        namespaces = self.ancestors + [self]
        all_filters = namespaces.map(&:befores).flatten
      when :after
        namespaces = [self] + self.ancestors.reverse
        all_filters = namespaces.map(&:afters).flatten
      else
        raise 'Invalid filter type. Use :before or :after'
      end
      all_filters.select{|f| f[:opts][:all] || self.send("#{type}s").include?(f) }
    end
    
  end
  
  #
  #
  #
  class Base
    
    include CommonMethods
    
    def initialize(route, opts={}, parent=nil, &block)
      @route = route
      @opts = opts
      @parent = parent
      @block = block
    end
  end
  
end