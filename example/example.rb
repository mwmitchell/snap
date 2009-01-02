
require '../lib/snap'

module Example
  
  class Web
    
    include Snap::App
    
    # override the main render method right inside the app...
    def render(tpl, opts={})
      super tpl, :layout=>'layout'
    end
    
    start do
      
      before :global=>true do
        puts 'global before'
      end
      
      before do
        puts '/ before'
      end
      
      get do
        @title = 'HOME'
        render 'home'
      end
      
      get 'config' do
        Snap.config.inspect
      end
      
      namespace 'contact' do
        before do
          puts 'before /contact!'
        end
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