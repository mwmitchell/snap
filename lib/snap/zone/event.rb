module Snap::Zone::Event
  
  include Snap::Context # access to request, response and config
  
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    
    attr_accessor :root_block
    
    # The root map method for the app
    def map(&block)
      self.root_block = block
    end
    
  end
  
  class Base
    
    include Snap::Context # access to request, response and config
    include Snap::Response::Helpers
    include Snap::Renderer
    
    attr_reader :zone, :options, :block
    
    def initialize(zone, options=nil, &block)
      @zone,@options,@block=zone,options,block
    end
    
    def method_missing(m,*args,&block)
      @zone.send(m,*args,&block) if @zone
    end
    
    def execute
      result = instance_eval &@block
      if format and f = format.resolve(request.format)
        result = instance_eval &f if f
      end
      result
    end
    
  end
  
end