class Snap::Config
  
  attr_accessor :mutex, :view_paths, :default_renderer, :env, :app
  
  def initialize
    @mutex=true
    @view_paths=[]
    @default_renderer = :erb
    @env = :development
  end
  
end