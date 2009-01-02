# A Rack dispatcher
# In your config.ru ->
#
#   require 'my_app'
#   app = Snap::Rack::Runner.new(MyApp.new)
#   run app
#
class Snap::Rack::Runner
  
  attr :app_klass
  
  def initialize(app_klass)
    @klass = app_klass
  end
  
  def call(env)
    app = @klass.new
    dispatcher = Snap::Dispatcher.new(app)
    req = Snap::Rack::Request.new(env)
    res = Snap::Rack::Response.new
    dispatcher.execute(req, res)
  end
  
end