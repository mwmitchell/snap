lambda do |p|
  $:.unshift p unless
    $:.include?(p) or $:.include?(File.expand_path(p))
end.call(File.dirname(__FILE__))

require 'rubygems'
require 'rack'
require 'core_ext'

module Snap
  
  module Version
    MAJOR = '0'
    MINOR = '4'
    REVISION = '2'
    def self.combined
      [MAJOR, MINOR, REVISION].join('.')
    end
  end
  
end

%W(
  config
  context
  initializer
  response
  request
  zone
  renderer
).each{|p|require "snap/#{p}"}