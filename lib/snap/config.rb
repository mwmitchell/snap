module Snap
  
  class Config < Hash
    
    attr :data
    attr :mode
    
    def initialize(hash, mode)
      @mode=mode
      super hash[mode]
    end
    
  end
  
end