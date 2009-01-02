require 'erubis'

module Snap::App::Renderer
  
  def render(*args)
    content = ''
    opts = args.last.is_a?(Hash) ? args.pop : {}
    template = opts[:template] || args.first
    if template
      template_file = search_view_paths(resolve_template_name(template))
      raise 'Template not found' unless template_file
      content = render_erb_file(template_file)
    end
    if opts[:layout]
      @content = content
      layout_file = search_view_paths(resolve_template_name(opts[:layout]))
      raise 'Layout not found' unless layout_file
      content = render_erb_file(layout_file)
    end
    content
  end
  
  protected
  
  def search_view_paths(template_name)
    Snap.config[:view_paths].detect do |path|
      tpl = path / template_name
      return tpl if File.exists?(tpl)
    end
    false
  end
  
  def resolve_template_name(name)
    name.to_s + '.' + @request.format.to_s + '.erb'
  end
  
  def render_erb_file(template)
    data = File.read(template)
    Erubis::Eruby.new(data).result(binding)
  end
  
end