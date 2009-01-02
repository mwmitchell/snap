class Snap::Dispatcher
  
  attr :app
  attr :request
  attr :response
  
  def initialize(app)
    @app=app
  end
  
  # builds the app's actions/routes
  # finds the appropriate action based on path_info and the request method
  # executes the execute_action_cycle method
  # returns the value from Rack::Response.finish
  def execute(req, res)
    @request = req
    @response = res
    app.build(@request, @response)
    action, route_params = find_action
    if action and route_params
      execute_action_cycle(action, route_params)
    else
      app.not_found
    end
    res.finish
  end
  
  protected
  
  # merges the route params to the request params
  # within a catch(:halt) block...
  # runs all before filters
  # executes the action, setting the return value to @response.body
  # executes all after filters
  # if :halt is thrown,
  # the return value from #catch (second arg in throw)
  # is inspected and if the value is a
  #   String: the value of the string becomes the response body
  #   Proc: the proc is execute within the app scope
  #   Hash: The keys of the hash are sent to the response
  def execute_action_cycle(action, route_params)
    @request.params.merge!(route_params)
    caught = catch(:halt) do
      action.ns.befores.each do |cb|
        app.instance_eval(&cb[:block])
      end
      @response.body = app.instance_eval(&action.block)
      action.ns.afters.each do |cb|
        app.instance_eval(&cb[:block])
      end
    end
    if caught
      case caught
      when String
        @response.body = caught
      when Proc
        @response.body = app.instance_eval(&caught)
      when Hash
        caught.each_pair do |k,v|
          @response.send("#{k}=", v)
        end
      end
    end
  end
  
  # finds the action based on the request.path_info and request.request_method
  # returns the action and route-params-hash in an array
  def find_action
    route_params = {}
    action = app.namespace.all_actions.detect do |action|
      if action.request_method == @request.request_method and 
        (route_params = Snap::Router.match(@request.path_info, action.full_route, action.opts))
        true
      else
        false
      end
    end
    [action, route_params]
  end
  
end