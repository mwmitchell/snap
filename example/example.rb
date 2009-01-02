
require '../lib/snap'

module Example
  
  class Web
    
    include Snap::App
    include Snap::App::Renderer
    
    start do
      
      get do
        render 'home'
      end
      
      get 'config' do
        Snap.config.inspect
      end
      
      namespace 'contact' do
        get{render 'contact'}
        post do
          throw :halt, 'Not working yet!'
        end
      end
      
      namespace 'snap' do
        get {render 'snap'}
        get 'go' do
          redirect 'http://github.com/mwmitchell/snap'
        end
      end
      
    end
    
  end
  
end