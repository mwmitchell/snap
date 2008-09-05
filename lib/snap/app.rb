module Snap
  
  module App
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      
      attr_accessor :root_block
      
      def start(&block)
        @root_block = block
      end
      
    end
    
  end
  
end