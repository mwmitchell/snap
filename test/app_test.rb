require File.join(File.dirname(__FILE__), 'test_helper')
class AppTest < SnapCase
  
  class AppZ
    include Snap::App
    start do
      
    end
  end
  
  def request
    Snap::Rack::Request.new Rack::MockRequest.env_for('/')
  end
  
  def response
    Snap::Rack::Response.new
  end
  
  def test_app
    app = AppZ.new
    assert_equal Snap::App::Namespace, app.namespace.class
  end
  
end