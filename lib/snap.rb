$:.delete_if {|v|v=~/TextMate/}

$:.unshift File.dirname(__FILE__) unless
  $:.include?(File.dirname(__FILE__)) or $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'rack'

class Proc
  
  #
  # grab the file and line number from to_s
  #
  def source
    @source ||= self.to_s.scan(/@(.*:\d+)\>/)
  end
  
end

module Snap
  autoload :App, 'snap/app'
  autoload :Context, 'snap/context'
  autoload :Request, 'snap/request'
  autoload :Demo, 'snap/demo'
  autoload :Config, 'snap/config'
  autoload :HashBlock, 'snap/hash_block'
end