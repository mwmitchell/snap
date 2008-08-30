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