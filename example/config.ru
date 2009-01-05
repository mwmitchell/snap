require 'rubygems'
require '../lib/snap'

use Rack::Reloader
use Rack::ShowStatus

Snap.env = env.to_s.to_sym if env

Snap::Config.configure do |config|
  
end

Snap::Config.configure :development do |config|
  
end

Snap::Config.configure :production do |config|
  
end

run Snap::Rack::Runner.new('example.rb', 'Example::Web')