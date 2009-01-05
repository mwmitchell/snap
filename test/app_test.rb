require File.join(File.dirname(__FILE__), 'test_helper')
class AppTest < SnapCase
  
  class AppX
    include Snap::App
    start do
      before :all=>true do
        @response.body << 'before filter from AppX'
      end
      get{'get / from AppX'}
      namespace 'sub' do
        get{'get /sub from AppX'}
      end
    end
  end
  
  class MainApp
    include Snap::App
    start do
      get{'get / from MainApp'}
      namespace 'appx' do
        before :all=>true do
          @response.body << 'before :all=>true filter from the main app'
        end
        use AppX
      end
    end
  end
  
  def request(path='/')
    Snap::Rack::Request.new Rack::MockRequest.env_for(path)
  end
  
  def response
    Snap::Rack::Response.new
  end
  
  def test_app_and_mixin_app
    req = request('/appx/sub')
    res = response
    app = MainApp.new
    
    # not yet created...
    assert_nil app.actions
    assert_nil app.namespaces
    
    dispatcher = Snap::Dispatcher.new(app)
    new_response = dispatcher.execute(req, res)
    
    assert_equal 4, app.actions.size
    assert_equal 5, app.namespaces.size
    
    assert_equal Snap::App::Namespace::Base, app.namespaces.first.class
    assert_equal ["before filter from AppX", "before :all=>true filter from the main app", "get /sub from AppX"], new_response.last.body
  end
  
end