module Snap::Event
  
  class Base
    
    include Snap::Negotiator
    include Snap::ResponseHelpers
    
    attr_reader :options
    attr_reader :block
    attr_accessor :request
    attr_accessor :response
    
    def initialize(options=nil, &block)
      @options,@block=options,block
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