require './example'

require 'rubygems'

use Rack::Reloader
use Rack::ShowStatus

Snap.env = env.to_s.to_sym if env

Snap.configure do |config|
  config[:view_paths] << 'blah' / 'blah' / 'blah'
end

Snap.configure :development do |config|
  
end

Snap.configure :production do |config|
  
end

run Snap::Rack::Runner.new(Example::Web)