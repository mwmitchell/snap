require File.join(File.dirname(__FILE__), '..', 'lib', 'snap')

app=Snap::Demo::Controllers::Root.new

rack_env=Rack::MockRequest.env_for('/admin/customers', {'REQUEST_METHOD'=>'GET', 'SERVER_PORT'=>'80'})
puts app.call(rack_env)

puts "
...

"


rack_env=Rack::MockRequest.env_for('/admin/customers/henry', {'REQUEST_METHOD'=>'PUT', 'SERVER_PORT'=>'80'})
puts app.call(rack_env)

puts "
...

"



rack_env=Rack::MockRequest.env_for('/', {'REQUEST_METHOD'=>'GET', 'SERVER_PORT'=>'80'})
puts app.call(rack_env)

puts "
...

"

rack_env=Rack::MockRequest.env_for('/admin', {'REQUEST_METHOD'=>'GET', 'SERVER_PORT'=>'80'})
puts app.call(rack_env)

puts "
...

"

rack_env=Rack::MockRequest.env_for('/admin/orders', {'REQUEST_METHOD'=>'POST', 'SERVER_PORT'=>'80'})
puts app.call(rack_env)

puts "
...

"


rack_env=Rack::MockRequest.env_for('/admin/products', {'REQUEST_METHOD'=>'GET', 'SERVER_PORT'=>'80'})
puts app.call(rack_env)

puts "
...

"

rack_env=Rack::MockRequest.env_for('/contact', {'REQUEST_METHOD'=>'GET', 'SERVER_PORT'=>'80'})
puts app.call(rack_env)

puts "
...

"

rack_env=Rack::MockRequest.env_for('/contact/the-boss', {'REQUEST_METHOD'=>'GET', 'SERVER_PORT'=>'80'})
puts app.call(rack_env)

puts "
...

"

rack_env=Rack::MockRequest.env_for('/admin/products/144/edit', {'REQUEST_METHOD'=>'GET', 'SERVER_PORT'=>'80'})
puts app.call(rack_env)



puts "
...

"

rack_env=Rack::MockRequest.env_for('/admin/products/144', {'REQUEST_METHOD'=>'GET', 'SERVER_PORT'=>'80'})
puts app.call(rack_env)