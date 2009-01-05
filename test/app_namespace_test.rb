require File.join(File.dirname(__FILE__), 'test_helper')
class AppNamespaceTest < SnapCase
  
  class MyApp
    include Snap::App
  end
  
  def my_app
    MyApp.new
  end
  
  def test_routes
    ns = Snap::App::Namespace::Base.new('admin') do
      namespace 'products' do
        namespace ':id' do
          
        end
      end
    end
    assert_equal 'admin', ns.route
    assert_equal 'admin', ns.full_route
    ns.execute(my_app)
    assert_equal 1, ns.children.size
    assert_equal 1, ns.children.first.children.size
    assert_equal 2, ns.descendants.size
    assert_equal 0, ns.ancestors.size
    #
    assert_equal 0, ns.descendants.map(&:actions).flatten.size
    #
    id_namespace = ns.children.first.children.first
    assert_equal ':id', id_namespace.route
    assert_equal 2, id_namespace.ancestors.size
    assert_equal 'admin/products/:id', id_namespace.full_route
  end
  
  def test_actions
    ns = Snap::App::Namespace::Base.new 'admin' do
      get{}
      post{}
      delete{}
      put{}
      head{}
      namespace 'products' do
        get ':id' do
          
        end
      end
    end
    ns.execute(my_app)
    assert_equal 6, (ns.actions + ns.descendants.map(&:actions).flatten).size
  end
  
end