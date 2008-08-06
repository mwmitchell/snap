module Snap::Renderers
  
  module Erubis
    def render(template)
      
    end
  end
  
end

module Snap::Renderer
  
  class << self
    attr_accessor :default_renderer_type
  end
  
  def self.renderer_types
    @renderers||={}
  end
  
  def self.renderer_instances
    @renderer_instances||={}
  end
  
  def renderer(type=nil)
    type=Snap::Renderer.default_renderer_type if type.nil?
    Snap::Renderer.renderer_instances[type]||=Snap::Renderer.renderer_types[type].call rescue raise "Invalid handler type: #{type}"
  end
  
  def render(template=nil)
    template
    #template=resolve_template(template)
    #renderer.render(template)
  end
  
  #
  # returns info for renderer, file ext and directory
  #
  def resolve_template(name)
    name
  end
  
end