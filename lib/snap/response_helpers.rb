module Snap::ResponseHelpers
  
  class FormatMapper
    
    def initialize
      @formats={}
    end
    
    def method_missing(m,&block)
      # check with mime-types here...
      @formats[m]=block
    end
    
    def resolve(format)
      @formats[format]
    end
    
  end
  
  def format
    @format_mapper||=FormatMapper.new
  end
  
  def redirect(path, *args)
    response.status=302
    headers 'Location' => path
    throw :halt, *args
  end
  
  def stop(*args)
    throw :halt, args
  end
  
  def headers(header = nil)
    response.headers.merge!(header) if header
    response.headers
  end
  
  alias :header :headers
  
end