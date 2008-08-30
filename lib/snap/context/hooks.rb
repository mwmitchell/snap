module Snap
  
  module Context
    
    module Hooks
  
      def before_blocks; @before_blocks||=[] end
      def after_blocks; @after_blocks||=[] end
  
      #
      # before :only=>:action
      # before :only=>[:action1,:action2]
      # before :except=>:action1
      # before :except=>[:action1, :action2]
      #
      def before(options=nil, &block)
        before_blocks << Snap::Event::Base.new(self, options, &block)
      end
  
      def after(options=nil, &block)
        after_blocks << Snap::Event::Base.new(self, options,&block)
      end
      
      #
      # Returns an array of responses from the before/after filters and action blocks:
      # 
      # [array_of_before_filter_responses, action_result_body, array_of_after_filter_response] 
      # 
      def execute_before_and_after_blocks(action, &block)
        result = []
        result << execute_before_blocks(action)
        result << yield
        result << execute_after_blocks(action)
        result
      end
  
      #
      # THE REQUEST NEEDS TO BE PASSED IN HERE
      #
      def execute_before_blocks(action)
        result = []
        result += parent.execute_before_blocks(action) if parent
        result += eval_blocks(before_blocks, action)
        result
      end
  
      #
      # THE REQUEST NEEDS TO BE PASSED IN HERE
      #
      def execute_after_blocks(action)
        result = []
        result += eval_blocks(after_blocks, action)
        result += parent.execute_after_blocks(action) if parent
        result
      end
  
      protected
  
      def eval_blocks(events, action)
        request,response=action.request,action.response
        result=[]
        events.select do |event|
          # no options, execute the block
          if event.options.nil?
            result << event.execute(request, response)
            next
          end
          # if options is a symbol (single action name) or an array of action names (like :only)
          if (event.options.is_a?(Symbol) and action.name==event.options) || (event.options.is_a?(Array) and event.options.include?(action.name))
            result << event.execute(request, response)
            next
          end
          # if options is a Hash...
          if event.options.is_a?(Hash)
            if event.options[:only]
              if event.options.is_a?(Array) and event.options[:only].include?(action.name)
                result << event.execute(request, response)
                next
              end
              if event.options[:only]==action.name
                result << event.execute(request, response)
              end
            end
            if event.options[:except]
              if event.options.is_a?(Array) and ! event.options[:except].include?(action.name)
                result << event.execute(request, response)
                next
              end
              if event.options[:except]!=action.name
                result << event.execute(request, response)
              end
            end
          end
        end # end eval_blocks
        result.reject{|v|v.nil?}
      end
    
    end
    
  end
  
end