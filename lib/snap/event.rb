module Snap::Event
  
  class Base
    
    include Snap::RequestHelpers
    include Snap::ResponseHelpers
    include Snap::ConfigHelpers
    
    attr_reader :options
    attr_reader :block
    attr_accessor :request
    attr_accessor :response
    
    def initialize(context, options=nil, &block)
      @context,@options,@block=context,options,block
    end
    
    def method_missing(m,*args,&block)
      @context.send(m,*args,&block) if @context
    end
    
    def execute(req, res)
      self.request=req
      self.response=res
      result = instance_eval &@block
      if format_mapper and f = format_mapper.resolve(request.format)
        result = instance_eval &f if f
      end
      result
    end
    
  end
  
end