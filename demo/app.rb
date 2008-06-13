require File.join(File.dirname(__FILE__), '..', 'lib', 'snap.rb')
require 'snap/demo'

#use Rack::Auth::Basic do |username, password|
#  'secret' == password
#end

run Rack::ShowStatus.new(
  Rack::ShowExceptions.new(
    Rack::Lint.new(
      Snap::Demo::App.new
    )
  )
)