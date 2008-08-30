class Snap::Config
  
  attr_reader :mutex, :view_paths, :default_renderer
  
  def initialize
    @mutex=true
    @view_paths=[]
    @default_renderer = :erb
  end
  
end