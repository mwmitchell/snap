module Snap
  
  module App
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      
      attr_accessor :start_block
      
      def start(&block)
        @start_block = block
      end
      
    end
    
  end
  
end