module SimpleApp; end
  
class SimpleApp::Root
  
  include Snap::App
  
  start do
    get {'The root path using GET'}
    context 'about' do
      get {"Snap is an experimental framework?!"}
      get 'the-author' do
        'Matt Mitchell is the author of Snap.'
      end
    end
  end
  
end