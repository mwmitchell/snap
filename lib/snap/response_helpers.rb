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
  
  def format_mapper
    @format_mapper||=FormatMapper.new
  end
  
  def format
    format_mapper
  end
  
  def redirect(path, *args)
    response.status=302
    headers 'Location' => path
    throw :halt, *args
  end
  
  def headers(header = nil)
    response.headers.merge!(header) if header
    response.headers
  end
  
  alias :header :headers
  
  def render(template=nil, variables={}, options={})
    options[:renderer]||=config.default_renderer
    m = "render_#{options[:renderer]}"
    config.view_paths.each do |p|
      template = File.read(File.join(p, "#{template}.#{request.format}.erb")) rescue nil
    end
    render_erb([self], erb_helpers, template, variables)
  end
  
  def erb_helpers
    [Snap::ViewHelper::Erubis]
  end
  
  def render_erb(variable_bindings, extensions, template, data={})
    variable_bindings.each do |o|
      o.instance_variables.each do |k|
        data[k[1..-1]]=o.instance_variable_get(k)
      end
    end
    context=Object.new
    extensions.each do |e|
      context.extend e
    end
    data.each do |k,v|
      context.instance_variable_set("@#{k}", v)
    end
    require 'erubis_ext'
    ::Erubis::BlockAwareEruby.new(nil, :trim=>false).process(template, context)
  end
  
end