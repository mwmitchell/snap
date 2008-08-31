module Snap
  
  module RequestHelpers
    
    def params(*args)
      @request.params(*args)
    end
    
    def request
      @request
    end
    
  end
  
end