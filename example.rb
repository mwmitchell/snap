
require 'lib/snap'

module Example
  
  class Web
    
    include Snap::App
    include Snap::App::Renderer
    
    start do
      
      get do
        'Home'
      end
      
      get 'contact' do
        'Contact'
      end
      
      namespace 'admin' do
        
        namespace 'products' do
          before {puts 'BEFORE!'}
          before do
            #throw :halt, :status=>500, :body=>'ServerError'
          end
          #before {puts "before CB 1 for #{self}"}
          #before {puts "before CB 2 for #{self}"}
          after do
            puts 'AFTER!'
          end
          get do
            
          end
          get 'new' do
            redirect 'http://www.posibul.com'
          end
          namespace ':id' do
            get do
              'render params[:id]'
            end
            get 'edit' do
              render
            end
          end
        end
        
        get do
          'Admin'
        end
        
      end
      
    end
    
  end
  
end

app = Example::Web.new
dispatcher = Snap::Rack::App.new(app)
env = Rack::MockRequest.env_for('/admin/products/10')
puts dispatcher.call(env).inspect