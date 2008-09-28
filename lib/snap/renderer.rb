module Snap::Renderer
  
  # use haml
  def haml(content, options = {}, &b)
    require 'haml'
    ::Haml::Engine.new(content).render(options[:scope] || self, options[:locals] || {}, &b)
  end
  
  # use markaby
  def markaby
    require 'markaby'
    Markaby::Builder.new
  end
  
  # should pass in "options" as the last arg, which would also contain the :renderer type
  def render(*args)
    send("#{config.default_renderer}" , *args)
  end
  
  def wrap(template, variables={}, options={})
    response.body = render(template, variables.merge({:content=>response.body.to_s}), options)
  end
  
  # default render method uses Erubis
  def erb(template=nil, variables={}, options={})
    
    template ||= @full_key.to_s
    
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
    ext << Snap::Renderer::Erubis::Helpers
    ext.each {|e|context.extend e}
    
    variables.each do |k,v|
      puts "Template variable assignment: #{k} - #{v}"
      context.instance_variable_set("@#{k}", v)
    end
    
    begin
      ::Erubis::EscapedEruby.new(nil, :trim=>false).process(template_code, context)
    rescue
      raise "Error in template: \"#{template}\": #{$!}"
    end
  end
  
  module Erubis
    
    module Helpers
      
      def capture(&blk)
        _old_buf, @_erb_buf = @_erb_buf, ""
        blk.call
        ret = @_erb_buf
        @_erb_buf = _old_buf
        ret
      end

      def content_tag(tag, attributes={}, &block)
        html="<#{tag}"
        html+=' '+html_attributes(attributes)
        html+=">#{capture(&block)}</#{tag}>"
      end

      def html_attributes(attrs)
        out=[]
        attrs.each do |k,v|
          out << "#{k}=\"#{v}\""
        end
        out.join(' ')
      end
      
    end
    
  end
  
end