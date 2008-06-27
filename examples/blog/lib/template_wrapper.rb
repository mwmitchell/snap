class TemplateWrapper
  
  extend Snap::Interceptor
  
  after do
    t=Erb::Renderer.new('templates/layouts/public.html.erb')
    @response.body = t.render(:content=>@response.body)
  end
  
end