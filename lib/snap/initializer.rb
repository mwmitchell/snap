class Snap::Initializer
  
  attr :config
  
  def initialize(&block)
    puts 'Initializing Snap!'
    @config = Snap::Context.config = Snap::Config.new
    yield @config if block_given?
  end
  
  def call(env)
    @config.after_initialize!
    req = Snap::Context.request = Snap::Request.new(env)
    res = Snap::Context.response = Rack::Response.new
    res['Content-Type']="text/#{req.format}"
    c = Snap::Zone::Base.new('/', {}, nil, &@config.app.class.root_block)
    c.execute(req, res)
    res.finish
  end
  
end