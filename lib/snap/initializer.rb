class Snap::Initializer
  
  def initialize(&block)
    puts 'Initializing Snap...'
    @config = Snap.config
    yield @config if block_given?
  end
  
  def call(env)
    request=Snap::Request.new(env)
    response=Rack::Response.new
    response.finish
    response['Content-Type']="text/#{request.format}"
    c=Snap::Context::Base.new('/') do
      load_script File.expand_path('app/events.rb')
    end
    c.execute(request, response)
  end
  
end