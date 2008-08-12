module Snap::Event
  
  class Base
    
    include Snap::Negotiator
    include Snap::ResponseHelpers
    
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
      instance_eval &@block
      if negotiator and f = negotiator.resolve(request.format)
        instance_eval &f if f
      end
    end
    
  end
  
end