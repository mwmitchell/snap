module Snap::ResponseHelpers
  
  class FormatMapper
    
    def initialize
      @formats={}
    end
    
    def method_missing(m,&block)
      # check with mime-types here...
      @formats[m]=block
    end
    
    def resolve(format)
      @formats[format]
    end
    
  end
  
  def format
    @format_mapper||=FormatMapper.new
  end
  
  def redirect(path, *args)
    response.status=302
    headers 'Location' => path
    throw :halt, *args
  end
  
  def stop(*args)
    throw :halt, args
  end
  
  def headers(header = nil)
    response.headers.merge!(header) if header
    response.headers
  end
  
  alias :header :headers
  
  # should pass in "options" as the last arg, which would also contain the :renderer type
  def render(*args)
    send("render_#{config.default_renderer}" , *args)
  end
  
  # default render method uses Erubis
  def render_erb(template=nil, variables={}, options={})
    
    template ||= @name.to_s
    
    require 'erubis_ext'
    
    template_code=''
    config.view_paths.each do |p|
      template_code = File.read(File.join(p, "#{template}.#{request.format}.erb")) rescue false
    end
    
    raise "Template not found or not set. Try passing in a template name or naming the current action?" if template_code==false
    
    bindings = options[:bindings]||=[]
    bindings << self
    bindings.each do |o|
      o.instance_variables.each do |k|
        variables[k[1..-1]]=o.instance_variable_get(k)
      end
    end
    
    context=Object.new
    
    ext = options[:extensions]||=[]
    ext << Snap::ViewHelper::Erubis
    ext.each {|e|context.extend e}
    
    variables.each do |k,v|
      context.instance_variable_set("@#{k}", v)
    end
    
    begin
      ::Erubis::BlockAwareEruby.new(nil, :trim=>false).process(template_code, context)
    rescue
      raise "Error in template: \"#{template}\": #{$!}"
    end
  end
  
  # use haml
  def render_haml(content, options = {}, &b)
    require 'haml'
    ::Haml::Engine.new(content).render(options[:scope] || self, options[:locals] || {}, &b)
  end
  
  # use markaby
  def markaby
    require 'markaby'
    Markaby::Builder.new
  end
  
end