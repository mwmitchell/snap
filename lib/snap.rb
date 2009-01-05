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
  autoload :Config, 'snap/config'
  
  # @env is the current app environment, :development by default
  # @root is the file path to the running app directory
  class << self
    attr_accessor :env, :root
  end
  
  @env = :development
  @root = File.expand_path('.')
  
  def self.config
    Snap::Config.config
  end
  
end