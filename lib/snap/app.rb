module Snap::App
  
  autoload :Action, 'snap/app/action'
  autoload :Namespace, 'snap/app/namespace'
  autoload :Renderer, 'snap/app/renderer'
  
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    
    attr_reader :namespace
    
    # Call this method with a block to start building your app
    def start(opts={}, &block)
      @namespace = Snap::App::Namespace.new '/', opts, &block
    end
    
  end
  
  #
  # "instance" methods...
  #
  
  include Snap::App::Renderer
  
  attr :request
  attr :response
  
  # #build must be called before the app can be used.
  # It sets the request and response variables
  # then creates all of the routes/actions
  def build(request, response)
    @request = request
    @response = response
    namespace.execute(self)
  end
  
  def filters_halted
    raise 'filters_halted'
  end
  
  def not_found
    throw :halt, :status=>404, :body=>'Not Found'
  end
  
  def redirect(path, *args)
    throw :halt, :headers=>{'Location'=>path}, :status=>301
  end
  
  def params
    @request.params
  end
  
  # the root namespace of the app (where all of the top-level actions and before/after filters are)
  def namespace
    self.class.namespace
  end
  
end