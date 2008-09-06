module SimpleApp; end

class SimpleApp::Root
  
  include Snap::App
  
  start do
    
    after do
      nav = <<-EOF
        <ul>
          <li><a href="/">home</a></li>
          <li><a href="/about">about</a></li>
          <li><a href="/about/ruby">about ruby</a></li>
          <li><a href="/markaby">markaby example</a></li>
        </ul>
      EOF
      response.body = "<h1>Snap!</h1><hr/>#{nav}#{response.body}<hr/>"
    end
    
    get {'The root path using GET'}
    
    get :markaby=>'markaby' do
      markaby.div do
        h3 "Render your HTML with Markaby?"
        ul do
          li "markaby is cool"
          li "It's fun to put view logic in your controllers :)"
          li "testing..."
        end
      end
    end
    
    context 'about' do
      get {"Snap is an experimental framework?!"}
      get 'ruby' do
        'Ruby -> http://www.ruby-lang.org'
      end
    end
  end
  
end