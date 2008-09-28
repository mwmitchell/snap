class Snap::Dispatcher
  
  include Snap::Context
  
  def dispatch!(root_zone)
    begin
      halted_content = catch :halt do
        run_safely do
          action=root_zone.find_action
          action.execute
        end
        nil
      end
      response.write halted_content if halted_content
    rescue
      if config.env == :production
        response.status=500
        response.body = ['Something has gone horribly wrong...']
      else
        raise $!
      end
    end
    response.finish
  end
  
  def run_safely
    if config.mutex
      mutex.synchronize { yield }
    else
      yield
    end
  end
  
  def mutex
    @@mutex ||= Mutex.new
  end
  
end