require File.join(File.dirname(__FILE__), 'common.rb')
require 'snap/demo'

#
#
#
describe Snap::Demo::App do
  
  before :each do
    @app_class = Snap::Demo::App
    @app=@app_class.new
  end
  
  it '(class) should respond to build' do
    @app_class.should respond_to(:build)
  end
  
  it "should respond to :call" do
    @app.should respond_to(:call)
  end
  
  it "should have a nil :request attribute until :call is executed" do
    @app.request.should == nil
  end
  
  it "should have a :request attribute after calling the call method" do
    @app.call(new_rack_env)
    @app.should respond_to(:request)
    @app.request.class.should == Snap::Request
  end

  it "should not fail when requesting a POST, GET, PUT or DELETE to /" do
    
    status,headers,body = @app.call(new_rack_env)
    body.collect.should == ['A GET request for /']
    status.should == 200
    headers.should == {'Content-Type'=>'text/plain'}
    
    status,headers,body=@app.call(new_rack_env('/', {'REQUEST_METHOD'=>'POST'}))
    body.collect.should == ['A POST request for /']
    status.should == 200
    headers.should == {'Content-Type'=>'text/json'}
    
    status,headers,body=@app.call(new_rack_env('/', {'REQUEST_METHOD'=>'PUT'}))
    body.collect.should == ['A PUT request for /']
    status.should == 200
    headers.should == {'Content-Type'=>'text/plain'}
    
    status,headers,body=@app.call(new_rack_env('/', {'REQUEST_METHOD'=>'DELETE'}))
    body.collect.should == ['A DELETE request for /']
    status.should == 200
    headers.should == {'Content-Type'=>'text/plain'}
    
  end

end