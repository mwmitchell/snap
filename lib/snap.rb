lambda {|p|$:.unshift p unless $:.include?(p) or $:.include?(File.expand_path(p))}.call(File.dirname(__FILE__))

require 'rubygems'
require 'rack'
require 'core_ext'

module Snap; end

%W(rack_runner response_helpers request negotiator event loader action context/action_methods context/hooks context renderers renderers/erubis).each{|p|require "snap/#{p}"}