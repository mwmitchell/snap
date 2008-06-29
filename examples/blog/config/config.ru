require File.expand_path(File.dirname(__FILE__) + '/init.rb')

run Rack::Builder.new {
  use Rack::CommonLogger, STDERR
  use Rack::ShowExceptions
  use Rack::Reloader
  use Rack::Lint
  run snap!
}.to_app