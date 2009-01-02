#
# The Namespace class is a container for actions and before/after filters
# It can contain child Namespaces and can have a parent Namespace
# It's block is executed within it's own scope, NOT the app
#   HINT: if you want to always execute some app code for a namespaced route, do it in a before/after filter!
#         Executing code within the Namespace block will not give you access to the app
#
class Snap::App::Namespace
  
  attr_reader :route, :parent, :children, :opts, :block, :actions
  
  def initialize(route, opts={}, parent=nil, &block)
    @route, @opts, @parent, @block = route, opts, parent, block
    @children = []
    @actions = []
  end
  
  # executes the namespace block, then recursively executes each child namespace
  # TODO: scope really isn't needed here
  def execute(scope)
    instance_eval(&@block) and children.each{|child|child.execute(scope)}
  end
  
  # gets all descendant actions
  def all_actions
    (actions + [children.map(&:all_actions)]).flatten
  end
  
  # creates a child namespace
  # namespace 'texts' do
  #   
  # end
  def namespace(route, opts={}, &block)
    @children << self.class.new(route, opts, self, &block)
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
        @actions << Snap::App::Action.new(self, :#{m}, route, opts, &blk)
      end
    EOF
  end
  
  def ancestors
    @parent ? [@parent] + @parent.ancestors : []
  end
  
  # calculates the full route: parent routes + this route
  def full_route
    if @parent
      routes = ancestors.reverse.map(&:route)
      (routes + [@route]).join('/').squeeze('/')
    else
      route
    end
  end
  
end