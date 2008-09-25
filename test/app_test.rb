require 'test/unit'
require 'snap'

class AppTest < Test::Unit::TestCase
  
  class App
    include Snap::App
  end
  
  def test_app_attributes
    assert App.respond_to?(:root_block)
    app = App.new
    assert app.config
  end
  
end