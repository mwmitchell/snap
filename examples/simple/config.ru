require '../../lib/snap.rb'

app = Snap::Initializer.new { |config|
  config.view_paths << 'app/views'
  #config.sessions=true
  #config.logging=true
  #config.static :urls=>'', :root=>''
  #config.mime :xml, 'application/xml'
}

Rack::File::MIME_TYPES[:xml] = 'application/xml'
Rack::File::MIME_TYPES[:js] = 'application/javascript'

app = Rack::Session::Cookie.new(app)
app = Rack::CommonLogger.new(app)
app = Rack::Static.new(app, :urls=>['/images', '/css', '/js'], :root=>'public')

run app