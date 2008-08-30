module Snap::Renderers
  
  module Helpers
    
    def render(renderer, template, options={})
      m = method("render_#{renderer}")
      m.call(resolve_template(renderer, template, options), options)
    end

    private
        
      def resolve_template(renderer, template, options, scream = true)
        case template
        when String
          template
        when Proc
          template.call
        when Symbol
          if proc = templates[template]
            resolve_template(renderer, proc, options, scream)
          else
            read_template_file(renderer, template, options, scream)
          end
        else
          nil
        end
      end
      
      def read_template_file(renderer, template, options, scream = true)
        path = File.join(
          options[:views_directory] || Sinatra.application.options.views,
          "#{template}.#{renderer}"
        )
        unless File.exists?(path)
          raise Errno::ENOENT.new(path) if scream
          nil
        else  
          File.read(path)
        end
      end
      
      def templates
        Sinatra.application.templates
      end
    
  end
  
end