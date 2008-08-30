module Snap
  
  module RequestHelpers
    
    def params(*args)
      @request.params(*args)
    end
    
  end
  
end