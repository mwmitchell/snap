module Snap::Response
  
  class FormatMapper
    
    attr_accessor :formats
    
    def initialize
      self.formats={}
    end
    
    Rack::File::MIME_TYPES.each do |m|
      instance_eval <<-EOF
        def #{m.first}(&block)
          formats[:#{m.first}]=block
        end
      EOF
    end
    
    def resolve(format)
      formats[format]
    end
    
    protected :formats
    
  end
  
  module Helpers
    
    attr :format_mapper
    
    def format
      self.format_mapper||=Snap::Response::FormatMapper.new
    end
    
    def redirect(path, *args)
      response.status=302
      headers 'Location' => path
      throw :halt, *args
    end
    
    def body
      response.body
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
  
end