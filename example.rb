
require 'lib/snap'

module Example
  
  class Web
    
    include Snap::App
    include Snap::App::Renderer
    
    start do
      
      get do
        'Home'
      end
      
      get 'contact' do
        'Contact!'
      end
      
    end
    
  end
  
end