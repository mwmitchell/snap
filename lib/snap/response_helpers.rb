module Snap::ResponseHelpers
  
  def redirect(path, *args)
    response.status=302
    headers 'Location' => path
    throw :halt, *args
  end
  
  def headers(header = nil)
    response.headers.merge!(header) if header
    response.headers
  end
  
  alias :header :headers
  
end