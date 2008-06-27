get{render 'pages/index'}

map 'about' do
  get{render 'views/about'}
end

map 'contact' do
  get{render 'views/contact'}
  post do
    
  end
end

map('posts'){use Blog::Controllers::Posts}