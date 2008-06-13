require File.join(File.dirname(__FILE__), '..', 'lib', 'pepper.rb')
require 'pepper/demo'

#use Rack::Auth::Basic do |username, password|
#  'secret' == password
#end

run Rack::ShowStatus.new(
  Rack::ShowExceptions.new(
    Rack::Lint.new(
      Pepper::Demo::Pickled.new
    )
  )
)