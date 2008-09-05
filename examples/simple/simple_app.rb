module SimpleApp; end

require 'haml'
  
class SimpleApp::Root
  
  include Snap::App
  
  start do
    
    after do
      nav = <<-EOF
        <ul>
          <li><a href="/">home</a></li>
          <li><a href="/about">about</a></li>
          <li><a href="/about/ruby">about ruby</a></li>
        </ul>
      EOF
      response.body = "<hr/>#{nav}#{response.body}<hr/>"
    end
    
    get {'The root path using GET'}
    context 'about' do
      get {"Snap is an experimental framework?!"}
      get 'ruby' do
        'Ruby -> http://ruby.com'
      end
    end
  end
  
end