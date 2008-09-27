module SimpleApp; end

class SimpleApp::Root
  
  include Snap::Zone::Event
  
  map do
    
    after do
      # wrap the pages up in a template
      wrap('main.layout', {}, {:bindings=>[@zone.action]})
    end
    
    get :index do
      @page_title = 'Welcome to Snaps\' simple demo.'
      render
    end
    
    map :about=>'about' do
      get :index do
        @page_title='About Snap!'
        render
      end
      get :rack=>'rack' do
        @page_title='About Rack'
        render
      end
    end
    
  end
  
end