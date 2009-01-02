# A Rack dispatcher
# In your config.ru ->
#
#   require 'my_app'
#   app = Snap::Rack::App.new(MyApp.new)
#   run app
#
class Snap::Rack::App
  
  attr :app
  
  def initialize(app)
    @app=app
  end
  
  def call(env)
    dispatcher = Snap::Dispatcher.new(@app)
    req = Snap::Rack::Request.new(env)
    res = Snap::Rack::Response.new
    dispatcher.execute(req, res)
  end
  
end