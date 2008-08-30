class Snap::Config
  
  attr_reader :mutex, :view_paths
  
  def initialize
    @view_paths=[]
    @mutex=true
  end
  
end