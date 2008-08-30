context '/' do
  
  before do
    'the grand-daddy before'
  end
  
  before do
    if request.params['halt']
      throw :halt, 'halting!'
    end
  end
  
  before do
    'before #2'
  end

  after do
    'after #1'
  end

  after do
    'after #2'
  end

  get do
    'This is the / action'
  end
  
end

context 'contact' do
  
  get do
    'This is the /contact action'
  end
  
  get ':who' do
    "This is the /content/#{local_params[:who]}"
  end
  
end