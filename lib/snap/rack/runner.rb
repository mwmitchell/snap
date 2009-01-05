# A Rack dispatcher
# In your config.ru ->
#
#   require 'my_app'
#   app = Snap::Rack::Runner.new(MyApp.new)
#   run app
#
class Snap::Rack::Runner
  
  attr :app_file
  attr :app_class
  
  def initialize(app_file, app_class)
    @app_file = app_file
    @app_class = app_class
  end
  
  def call(env)
    require @app_file
    app = constantize(@app_class).new
    dispatcher = Snap::Dispatcher.new(app)
    dispatcher.execute(Snap::Rack::Request.new(env), Snap::Rack::Response.new)
  end
  
  # from activesupport
  def constantize(klass_name)
    names = klass_name.split('::')
    names.shift if names.empty? || names.first.empty?
    constant = Object
    names.each do |name|
      constant = constant.const_get(name) || constant.const_missing(name)
    end
    constant
  end
  
end