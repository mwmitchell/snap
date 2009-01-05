class Snap::App::Action
  
  attr_accessor :ns
  attr_reader :request_method, :route, :opts, :block
  
  def initialize(ns, request_method, route, opts={}, &block)
    @ns, @request_method, @route, @opts, @block = ns, request_method, route, opts, block
  end
  
  def full_route
    [@ns.full_route, @route].join('/').squeeze('/')
  end
  
end