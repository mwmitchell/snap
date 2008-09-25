class Snap::Config
  
  attr_accessor :mutex, :view_paths, :env, :app, :default_renderer
  
  attr :after_initialize_block
  
  def initialize
    @mutex=true
    @view_paths=[File.join(File.expand_path('.'), 'views')]
    @env = :development
    @default_renderer = :erb
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