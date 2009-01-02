
require '../lib/snap'

module Example
  
  class Web
    
    include Snap::App
    include Snap::App::Renderer
    
    start do
      
      get do
        'Snap Home'
      end
      
      namespace 'contact' do
        get{'Contact'}
        post do
          throw :halt, 'Not working yet!'
        end
      end
      
      namespace 'snap' do
        get {'Snap is a Ruby web framework'}
        get 'go' do
          redirect 'http://github.com/mwmitchell/snap'
        end
      end
      
    end
    
  end
  
end