before do
  format.html do
    response.write 'GLOBAL BEFORE' + '<hr/>'
  end
end

after do
  format.html do
    response.write '<hr/> GLOBAL AFTER'
  end
end

before do
  if request.params['halt']
    response.status = 500
    throw :halt, 'Halt!'
  end
end

context '/' do
  
  before do
    response.write '<div style="padding:1em; border:solid 1px darkblue;">nested before...</div>'
  end

  after do
    response.write '<div style="padding:1em; border:solid 1px darkblue;">nested after...</div>'
  end

  get do
    @title = 'Welcome!'
    render 'pages/index'
  end
  
end

context 'contact' do
  
  before do
    '<h1>Contact</h1>'
  end
  
  get do
    'This is the /contact action'
  end
  
  get ':who' do
    "This is the /content/#{local_params[:who]}"
  end
  
end