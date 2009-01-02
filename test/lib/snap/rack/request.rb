class Snap::Rack::Request < Rack::Request
  
  def initialize(env)
      super(env)
      pi=env['PATH_INFO'].to_s.split('.')
      @path_info=pi.first.squeeze('/')
      @format=pi.size==2 ? pi.last.to_sym : default_format
      @request_method=env['REQUEST_METHOD'].downcase.to_sym
      if post_tunnel_method_hack?
        @request_method = params['_method'].downcase.to_sym
      end
    end
    
    def default_format
      accept_encoding || :html
    end
    
    def format
      @format
    end
    
    def path_info
      @path_info
    end
    
    # Set of request method names allowed via the _method parameter hack. By default,
    # all request methods defined in RFC2616 are included, with the exception of
    # TRACE and CONNECT.
    POST_TUNNEL_METHODS_ALLOWED = [:put, :delete, :head]
    
    # Return the HTTP request method with support for method tunneling using the POST
    # _method parameter hack. If the real request method is POST and a _method param is
    # given and the value is one defined in +POST_TUNNEL_METHODS_ALLOWED+, return the value
    # of the _method param instead.
    def request_method
      @request_method
    end

    private

      # Return truthfully if and only if the following conditions are met: 1.) the
      # *actual* request method is POST, 2.) the request content-type is one of
      # 'application/x-www-form-urlencoded' or 'multipart/form-data', 3.) there is a
      # "_method" parameter in the POST body (not in the query string), and 4.) the
      # method parameter is one of the verbs listed in the POST_TUNNEL_METHODS_ALLOWED
      # list.
      def post_tunnel_method_hack?
        @request_method == :post &&
          POST_TUNNEL_METHODS_ALLOWED.include?(self.POST.fetch('_method', '').downcase.to_sym)
      end
end