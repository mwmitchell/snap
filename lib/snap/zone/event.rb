module Snap::Zone::Event
  
  autoload :Action, 'snap/zone/event/action'
  
  class Base
    
    include Snap::ResponseHelpers
    include Snap::Context
    
    attr_reader :zone, :options, :block
    
    def initialize(zone, options=nil, &block)
      @zone,@options,@block=zone,options,block
    end
    
    def method_missing(m,*args,&block)
      @zone.send(m,*args,&block) if @zone
    end
    
    def execute
      result = instance_eval &@block
      if format_mapper and f = format_mapper.resolve(request.format)
        result = instance_eval &f if f
      end
      result
    end
    
  end
  
end