class Snap::RackRunner
  
  def initialize(klass)
    @klass=klass
  end
  
  def call(env)
    request=Snap::Request.new(env)
    response=Rack::Response.new
    c=@klass.new('', &lambda{load('app.rb')})
    c.execute(request, response)
    response['Content-Type']="text/#{request.format}"
    response.finish
  end
  
end