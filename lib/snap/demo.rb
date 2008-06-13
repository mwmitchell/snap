module Snap::Demo

  class App
    
    include Snap::App
    
    build do
      
      header 'Content-Type', 'text/html'
      
      header 'Content-Type', 'text/plain'
      
      get do
        'A GET request for /'
      end
      
      post do
        header 'Content-Type', 'text/json'
        'A POST request for /'
      end
      
      put{'A PUT request for /'}
      
      delete{'A DELETE request for /'}
      
    end
    
  end
  
end