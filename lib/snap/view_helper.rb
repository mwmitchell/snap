module Snap::ViewHelper
  
  module Erubis
    
    def url
      
    end
    
    def capture(&blk)
      _old_buf, @_erb_buf = @_erb_buf, ""
      blk.call
      ret = @_erb_buf
      @_erb_buf = _old_buf
      ret
    end
    
    def content_tag(tag, attributes={}, &block)
      html="<#{tag}"
      html+=' '+html_attributes(attributes)
      html+=">#{capture(&block)}</#{tag}>"
    end
    
    def html_attributes(attrs)
      out=[]
      attrs.each do |k,v|
        out << "#{k}=\"#{v}\""
      end
      out.join(' ')
    end
    
  end
  
end