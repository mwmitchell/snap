module Snap::Negotiator
  
  class Base
    
    def initialize
      @formats={}
    end
    
    def method_missing(m,&block)
      # check with mime-types here...
      @formats[m]=block
    end
    
    def resolve(format)
      @formats[format]
    end
    
  end
  
  def negotiator
    @negotiator||=Base.new
  end
  
  def format
    negotiator
  end
  
end