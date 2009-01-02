require 'rubygems'
require 'rack'

proc {|base, files|
  $: << base unless $:.include?(base) || $:.include?(File.expand_path(base))
  files.each {|f| require f}
}.call(File.dirname(__FILE__), ['snap_core_ext'])

module Snap
  
  autoload :App, 'snap/app'
  autoload :Dispatcher, 'snap/dispatcher'
  autoload :Rack, 'snap/rack'
  autoload :Router, 'snap/router'
  
end