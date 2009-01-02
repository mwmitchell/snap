require File.join(File.dirname(__FILE__), 'test_helper')
class RouterTest < SnapCase
  
  def test_basic
    input = '/basic/static/path'
    route = '/basic/static/path'
    assert_equal Hash.new, Snap::Router.match(input, route)
  end
  
  def test_ignores_trailing_slashes
    input = '/basic/static/path/'
    route = 'basic/static/path'
    assert_equal Hash.new, Snap::Router.match(input, route)
  end
  
  def test_failing_match
    input = '/zxcv/zxcv'
    route = '/basic/static/path'
    assert_equal nil, Snap::Router.match(input, route)
  end
  
  def test_route_params_with_trailing_slashes
    input = 'users/1/tags/190'
    route = '/users/:user_id/tags/:user_tag_id/'
    match = Snap::Router.match(input, route)
    assert_equal '1', match[:user_id]
    assert_equal '190', match[:user_tag_id]
  end
  
end