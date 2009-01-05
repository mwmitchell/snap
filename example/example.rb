
require '../lib/snap'

module Example
  
  class Web
    
    include Snap::App
    
    # override the main render method right inside the app...
    # all actions and before/after filters are executed within the scope of the Example::Web instance
    # which also gets helper methods from Snap::App
    def render(tpl, opts={})
      super tpl, :layout=>'layout'
    end
    
    start do
      
      before :all=>true do
        @title = 'Blah!'
        @response.body << 'the root namespace BEFORE ALL filter<br/>'
      end
      
      after do
        @response.body << 'the root namespace AFTER filter<br/>'
      end
      
      after :all=>true do
        @response.body << 'the root namespace AFTER ALL filter<br/>'
      end
      
      get do
        @title = 'HOME'
        render 'home'
      end
      
      get 'config' do
        render 'config'
      end
      
      namespace 'contact' do
        before do
          @response.body << 'the before /contact filter<br/>'
        end
        after do
          @response.body << 'the after /contact filter<br/>'
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