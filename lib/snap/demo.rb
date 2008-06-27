module Snap::Demo
 
  module Controllers
    
    module Admin
      
      class Customers
        
        extend Snap::App
        
        map do
          
          extend Snap::Context::Actions
          
          index do
            'Admin::Customers INDEX /admin/customers -> ' + path
          end
          
          update :customer_name=>/\w+/ do
            app.response.write 'TESTING'
            "Admin::Customers UPDATE /admin/customers/#{params[:customer_name]} -> " + path
          end
          
        end
        
      end
      
      class Products
        
        extend Snap::App
        
        map do
          
          extend Snap::Context::Actions
          
          before do
            puts "Admin::Products BEFORE"
          end
          
          after do
            puts "Admin::Products AFTER"
          end
          
          get{'Admin::Products GET /admin/products -> ' + path}
          
          map :product_id=>:digit do
            get do 
              out = "Admin::Products GET /admin/products/#{params[:product_id]} -> #{path}"
              out += "\nThe parent path is #{parent.path}"
            end
          end
          
          edit do
            out = "Admin::Products EDIT /admin/products/#{params[:id]}/edit -> " + path
            out += "\nThe parent path is #{parent.path}"
          end
          
          index do
            'Admin::Products INDEX /admin/products'
          end
          
          new :server_name=>/example/ do
            'Admin::Products NEW /admin/products'
          end
          
        end
      end
      
    end
    
    class Contact
      
      extend Snap::App
      
      map do
        
        before{puts "Contact BEFORE"}
        after{puts "Contact AFTER"}
        
        get{'Contact GET /'}
        
        map 'the-boss' do
          before do
            puts 'Contact BEFORE /the-boss'
          end
          after do
            puts 'Contact AFTER /the-boss'
          end
          get{'Contact GET /the-boss -> ' + path}
        end
        
      end
    end
    
    class Root
      
      extend Snap::App
      
      attr_accessor :count

      map do
        
        before do
          puts 'Root BEFORE /'
        end
        
        after do
          puts 'Root AFTER /'
        end
        
        get{'GET /'}
        post{'POST /'}
        put{'PUT /'}
        delete{'DELETE /'}
        
        map :contact do
          before do
            puts 'Root BEFORE /contact'
          end
          after do
            puts 'Root AFTER /contact'
          end
          map 'the-boss' do
            before :post do
              puts 'Root BEFORE-POST /contact/the-boss'
            end
            after :post do
              puts 'Root AFTER-POST /contact/the-boss'
            end
            post{'Root POST /contact'}
          end
          use Contact
        end
        
        map :admin do
          map(:products){use Admin::Products}
          map(:customers){use Admin::Customers}
          map :orders do
            post{'Root POST /admin/orders'}
          end
        end
        
        #
        #
        #
        map :admin do
          before do
            puts "Root BEFORE /admin"
          end
          after do
            puts "Root AFTER /admin"
          end
          get{'Root GET /admin'}
          map :orders, :server_port=>/^8/ do
            get :server_port=>80 do
              ':80 GET /admin/orders'
            end
            get :server_port=>81 do 
              ':81 GET /admin/orders'
            end
          end
        end
      end
     
    end
   
  end
 
end