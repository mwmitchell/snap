#
#
#
module Snap::Context::Events
  
  include Snap::Context::Matcher
  
  def before_blocks; @before_blocks||={} end
  def after_blocks; @after_blocks||={} end
  
  def before(action=:all, options={}, &block)
    before_blocks[action]=[options,block]
  end
  
  def after(action=:all, options={}, &block)
    after_blocks[action]=[options,block]
  end
  
  def execute_before_and_after_blocks(method, options, &block)
    execute_before_blocks method, options
    yield
    execute_after_blocks method, options
  end
  
  #
  #
  #
  def execute_before_blocks(method, options={})
    parent.execute_before_blocks(method, options) if parent
    b=(@before_blocks[method] || @before_blocks[:all]) if @before_blocks
    instance_eval(&b[1]) if b and options_match?(b[0], options)
  end
  
  #
  #
  #
  def execute_after_blocks(method, options={})
    b=(@after_blocks[method] || @after_blocks[:all]) if @after_blocks
    instance_eval(&b[1]) if b and options_match?(b[0], options)
    parent.execute_after_blocks(method, options) if parent
  end
  
end