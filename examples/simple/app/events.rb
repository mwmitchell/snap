before do
  format.html do
    puts 'GLOBAL BEFORE'
    response.write 'GLOBAL BEFORE' + '<hr/>'
  end
end

after do
  format.html do
    puts 'GLOBAL AFTER'
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
  
  after do
    puts 'CONTACT BEFORE'
    response.write '<div style=""><h1>Contact</h1>' + response.body.to_s + '</div>'
  end
  
  #pre_exe 
  #post_exe
  #filter :before
  
  get do
    'This is the /contact action'
  end
  
  get ':who' do
    "This is the /content/#{local_params[:who]}"
  end
  
end