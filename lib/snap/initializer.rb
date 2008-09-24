class Snap::Initializer
  
  def initialize(&block)
    puts 'Initializing Snap!'
    @config = Snap.config
    yield @config if block_given?
  end
  
  def call(env)
    request=Snap::Request.new(env)
    response=Rack::Response.new
    response['Content-Type']="text/#{request.format}"
    c = Snap::Context::Base.new ('/', {}, nil, &@config.app.class.start_block)
    c.execute(request, response)
    response.finish
  end
  
end