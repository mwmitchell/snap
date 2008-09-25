module Snap
  
  module App
    
    include Snap::Context
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      
      attr :root_block
      
      # The root map method for the app
      def map(&block)
        @root_block = block
      end
      
    end
    
  end
  
end