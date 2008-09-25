class Snap::Config
  
  attr_accessor :mutex, :view_paths, :default_renderer, :env, :app
  
  attr :after_initialize_block
  
  def initialize
    @mutex=true
    @view_paths=[]
    @default_renderer = :erb
    @env = :development
  end
  
  # sets the callback block
  def after_initialize(&block)
    @after_initialize_block=block
  end
  
  # executes the callback block
  def after_initialize!
    @after_initialize_block.call(self) if @after_initialize_block
  end
  
end