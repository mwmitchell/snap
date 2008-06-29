before do
  response.write(
    "
    <div style='border:solid 1px gray; padding 1em;'>
    <div><a href='/about'>about</a> | <a href='/contact'>contact</a> | <a href='/'>home</a></div>"
  )
end

after do
  response.write '</div>'
end

get do
  response.write(
    '<form method="post">
      <input type="submit" />
    </form>
    '
  )
end

post{response.write "Posted! Go <a href='#{path}'>back</a>..."}

map 'action' do
  before {response.write '<h1>ABOUT WITH ID ' + self.value + '</h1>'}
  get{response.write("views/about"*10000)}
end

map 'about' do
  before {response.write '<h1>ABOUT WITH NO ?id</h1>'}
  get{response.write("views/about"*10000)}
end

map :request do
  get{response.write 'REQUESTING...'}
  map :type=>:word do
    get{response.write params.inspect}
  end
end

map 'contact' do
  get{response.write 'views/contact'}
  post do
    
  end
end