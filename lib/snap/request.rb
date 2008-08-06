class Snap::Request < Rack::Request
  
  def initialize(env)
    super(env)
    pi=env['PATH_INFO'].to_s.split('.')
    @path_info=pi.first.cleanup('/')
    @format=pi.size==2 ? pi.last.to_sym : default_format
    @request_method=env['REQUEST_METHOD'].downcase.to_sym
  end
  
  def default_format; :html end
  
  def format
    @format
  end
  
  def path_info
    @path_info
  end
  
  def request_method
    @request_method
  end
  
end