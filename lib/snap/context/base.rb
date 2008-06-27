###
class Snap::Context::Base
  
  include Snap::Context::Events
  include Snap::Context::Matcher
  
  attr :pattern
  attr :options
  attr_accessor :parent
  attr :block
  attr :app
  attr :slices
  attr :value
  
  def initialize(pattern, options={}, parent=nil, &block)
    @pattern=pattern
    @options=options
    @parent=parent
    @block=block
  end
  
  [:get,:post,:put,:delete].each do |m|
    class_eval <<-EOF
      def #{m}(options={},&block)
        # don't add the action if the block is the same as existing action block
        unless actions.detect{|a|a[2].source==block.source}
          actions << [:#{m},options,block]
        end
      end
    EOF
  end
  
  def app; @app end
  def request; app.request end
  def response; app.response end
  def params; request.params end
  def actions; @actions||=[] end
  def children; @children||=[] end
  
  #
  # builds the url path to this context
  #
  def path
    @path ||= ((parent ? parent.path : '') + '/' + value).gsub(/\/+/, '/')
  end
  
  #
  # +use+ is the method that allows context to delegate
  # to other contexts, alloing logic to be off-loaded
  # to other classes. The klass argument
  # must be the class name of an object that is
  # using "extend Snap::App"
  #
  def use(klass,*args,&block)
    usable_app=klass.new(*args,&block)
    usable_app.class.root.parent=self
    children<<usable_app
  end
  
  #
  # Define a new sub-context block
  # pattern can be a string, a symbol or a hash
  #
  def map(pattern,options={},&block)
    # don't add the context if the block is the same as existing action block
    return if children.detect{|c|c.block.source == block.source}
    children<<self.class.new(pattern,options,self,&block)
  end
  
  #
  #
  #
  def find_action(method, env={})
    actions.detect{ |a| a[0] == method and options_match?(a[1], env)}
  end
  
  #
  #
  #
  def can?(*args)
    ! find_action(*args).nil?
  end
  
  #
  #
  #
  def method_missing(m,*a,&block)
    @app.send(m,*a,&block)
  end
  
  #
  #
  #
  def execute(method=request.m, env=request.env)
    a=find_action(method,env)
    result=nil
    unless a.nil?
      execute_before_and_after_blocks(method, env){result=instance_eval &a[2]}
    end
    result
  end
  
  #
  #
  #
  def resolve(slices, app)
    @app=app
    
    method=app.request.m
    env=app.request.env
    
    # 
    # must clone the slices; in some cases we need to climb back up the context stack
    # for example, if two contexts are defined with the same pattern
    # but the first one doesn't define a matching action block,
    # we need to be able to move back up to get the second one.
    # if the slices aren't cloned, then the 2nd one
    # would get a wrongly manipulated slices array - oh no!
    # 
    slices=slices.clone
    
    # try to match the @pattern with the given slices
    # then extract the value
    val = match?(@pattern,slices.first)
    
    return unless val    
    
    #
    # now make sure that the options can match the env
    #
    return unless options_match?(@options, env)
    
    # if the returned value was a hash, merge it into the apps request.param hash
    app.request.params.merge!(val) if val.is_a?(Hash)
    
    #
    # shift off the first item, save it as the value
    # of this context this is needed so that the
    # next context can have the next
    # value in the slices array
    #
    @value=slices.shift
    
    @slices=slices
    
    result = catch :halt do
      instance_eval &@block
    end
    
    return self if slices.empty? and can?(method, env)
    
    matching_child=nil
    children.each do |c|
      if c.is_a?(self.class)
        # standard Snap::Context::Base instance set by +map+
        matching_child=c.resolve(slices, app)
        # matching_child.parent=self if matching_child
      else
        # if this is an object set by the +use+ method
        # c is not a Snap::Context::Base; it
        # should be a class calling "extend Snap::App"
        # (a sort of sub-application)
        # so it needs a root slash for it's
        # own "root" context...
        # set the sub-app's request and response instances
        c.request=request
        c.response=response
        matching_child=c.class.root.resolve(['/']+slices,c)
      end
      return matching_child if matching_child
    end
    nil
  end
  
end