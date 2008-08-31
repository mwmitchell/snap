class Snap::Config
  
  attr_reader :mutex, :view_paths, :default_renderer, :env
  
  def initialize
    @mutex=true
    @view_paths=[]
    @default_renderer = :erb
    @env = :development
  end
  
end