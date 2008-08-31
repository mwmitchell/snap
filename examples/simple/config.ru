require '../../lib/snap.rb'

app = Snap::Initializer.new { |config|
  config.view_paths << 'app/views'
}

Rack::File::MIME_TYPES[:xml] = 'application/xml'
Rack::File::MIME_TYPES[:js] = 'application/javascript'

app = Rack::Session::Cookie.new(app)
app = Rack::CommonLogger.new(app)

run app