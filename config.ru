require './example'

require 'rubygems'
require 'rack/cache'

use Rack::CommonLogger, STDOUT
use Rack::ShowExceptions
use Rack::Reloader

#use(Rack::Cache, {
#  :verbose     => true,
#  :metastore   => 'file:/tmp/cache/rack/meta',
#  :entitystore => 'file:/tmp/cache/rack/body'
#})

run Snap::Rack::Runner.new(Example::Web)