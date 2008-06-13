$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'snap'
require 'spec'

def new_rack_env(path='/', attrs={})
  Rack::MockRequest.env_for(path, attrs)
end