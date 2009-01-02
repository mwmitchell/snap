# The optional renderer module
# Add this to your app if you want to use Snap's rendering system:
# module MyApp
#   include Snap::App
#   include Snap::App::Renderer
# end
module Snap::App::Renderer
  
  # TODO: implement this thing
  def render(*args)
    opts = args.last.is_a?(Hash) ? args.pop : {}
    opts[:template] ||= (
      
    )
  end
  
end