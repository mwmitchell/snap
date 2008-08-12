module Snap::Context::Hooks
  
  def before_blocks; @before_blocks||=[] end
  def after_blocks; @after_blocks||=[] end
  
  #
  # before :only=>:action
  # before :only=>[:action1,:action2]
  # before :except=>:action1
  # before :except=>[:action1, :action2]
  #
  def before(options=nil, &block)
    before_blocks << Snap::Event::Base.new(self,options, &block)
  end
  
  def after(options=nil, &block)
    after_blocks << Snap::Event::Base.new(self,options,&block)
  end
  
  def execute_before_and_after_blocks(action, &block)
    execute_before_blocks action
    yield
    execute_after_blocks action
  end
  
  #
  # THE REQUEST NEEDS TO BE PASSED IN HERE
  #
  def execute_before_blocks(action)
    parent.execute_before_blocks(action) if parent
    eval_blocks(before_blocks, action)
  end
  
  #
  # THE REQUEST NEEDS TO BE PASSED IN HERE
  #
  def execute_after_blocks(action)
    eval_blocks(after_blocks, action)
    parent.execute_after_blocks(action) if parent
  end
  
  protected
  
  def eval_blocks(events, action)
    request,response=action.request,action.response
    events.each do |event|
      # no options, execute the block
      if event.options.nil?
        event.execute(request, response)
        next
      end
      # if options is a symbol (single action name) or an array of action names (like :only)
      if (event.options.is_a?(Symbol) and action.name==event.options) || (event.options.is_a?(Array) and event.options.include?(action.name))
        event.execute(request, response)
        next
      end
      # if options is a Hash...
      if event.options.is_a?(Hash)
        if event.options[:only]
          if event.options.is_a?(Array) and event.options[:only].include?(action.name)
            event.execute(request, response)
            next
          end
          if event.options[:only]==action.name
            event.execute(request, response)
          end
        end
        if event.options[:except]
          if event.options.is_a?(Array) and ! event.options[:except].include?(action.name)
            event.execute(request, response)
            next
          end
          if event.options[:except]!=action.name
            event.execute(request, response)
          end
        end
      end
    end # end eval_blocks
    
  end
end