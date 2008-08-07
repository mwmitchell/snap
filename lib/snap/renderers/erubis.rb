require 'rubygems'
require 'erubis'

module ::Erubis
  
  # Taken from: http://github.com/wycats/merb-core/tree/7043503871759eadc947bc5138ebbc96b8e17d74/experimentation/experiments/erubis.rb
  
  module BlockAwareEnhancer
    def add_preamble(src)
      src << "_old_buf, @_erb_buf = @_erb_buf, ''; "
    end
    
    def add_postamble(src)
      src << "\n" unless src[-1] == ?\n
      src << "_ret = @_erb_buf; @_erb_buf = _old_buf; _ret.to_s\n"
    end
    
    def add_text(src, text)
      src << " @_erb_buf << '" << text << "'; "
    end
    
    def add_expr_escaped(src, code)
      src << ' @_erb_buf << ' << escaped_expr(code) << ';'
    end
    
    def add_expr_literal(src, code)
      unless code =~ /(do|\{)(\s*|[^|]*|)?\s*$/
        src << ' @_erb_buf << (' << code << ').to_s;'
      else
        src << ' @_erb_buf << ' << code << "; "
      end
    end
  end
  
  class BlockAwareEruby < ::Erubis::EscapedEruby
    include BlockAwareEnhancer
  end
  
end

module ::Snap::Renderers
  
  module Erubis
    
    class Context
      
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
    
    def render(template, data={})

      instance_variables.each do |k|
        data[k[1..-1]]=instance_variable_get(k)
      end

      action.instance_variables.each do |k|
        data[k[1..-1]]=action.instance_variable_get(k)
      end

      context=Context.new
      data.each do |k,v|
        context.instance_variable_set("@#{k}", v)
      end

      template = File.read("views/#{template}.#{request.format}.erb")
      response.write ::Erubis::BlockAwareEruby.new(nil, :trim=>false).process(template, context)
    end
  end
  
end