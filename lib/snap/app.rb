module Snap::App
  
  autoload :Action, 'snap/app/action'
  autoload :Namespace, 'snap/app/namespace'
  autoload :Renderer, 'snap/app/renderer'
  
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    
    attr_reader :start_block, :start_opts
    
    # Call this method with a block to start building your app
    def start(opts={}, &block)
      @start_block = block
      @start_opts = opts
    end
    
  end
  
  #
  # "instance" methods...
  #
  
  include Snap::App::Renderer
  
  attr_reader :request, :response, :namespaces, :actions
  
  # #build must be called before the app can be used.
  # It sets the request and response variables
  # then creates all of the routes/actions
  def build(request, response)
    @actions = []
    @namespaces = []
    @request = request
    @response = response
    @namespaces << Snap::App::Namespace::Base.new('/', self.class.start_opts, &self.class.start_block)
    @namespaces.first.execute(self)
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
  
end