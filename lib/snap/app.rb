#
#
#

require 'monitor'

module Snap::App
  
  attr :root
  
  #
  #
  #
  def map(options={}, &block)
    @root=Snap::Context::Base.new('/', options, nil, &block)
  end
  
  #
  #
  #
  def self.extended(base)
    base.class_eval do
      
      #
      # Provides sync functionality when using Threads and shared resources
      #
      include MonitorMixin
      
      attr_accessor :request
      attr_accessor :response
      
      #
      #
      #
      def call(rack_env)
        synchronize do
          @request = Snap::Request.new(rack_env)
          @response = Rack::Response.new
          c=self.class.root.resolve(@request.path_info_slices, self)
          result = c.execute if c
        end
      end
      
    end
  end
  
end