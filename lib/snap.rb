lambda do |p|
  $:.unshift p unless
    $:.include?(p) or $:.include?(File.expand_path(p))
end.call(File.dirname(__FILE__))

require 'rubygems'
require 'rack'
require 'core_ext'

module Snap
  
  class << self; attr :config end
  
  def self.config
    @config ||= Snap::Config.new
  end
  
  module Version
    MAJOR = '0'
    MINOR = '4'
    REVISION = '0'
    def self.combined
      [MAJOR, MINOR, REVISION].join('.')
    end
  end
  
end

%W(
  config
  config_helpers
  initializer
  response_helpers
  request_helpers
  request
  event
  action
  context/filters
  context
  view_helper
  app
).each{|p|require "snap/#{p}"}