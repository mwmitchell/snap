
extend Snap::Renderers::Erubis

map 'erb' do
  get do
    @title='Erubis Example'
    @body='Erubis is a fast, secure, and very extensible implementation of eRuby. It has the following features.'
    render 'pages/erb'
  end
end

before :except=>:home do
  format.html{response.write '<ul><li>'}
  format.xml{response.write '<root>'}
end

after :except=>:home do
  format.html{response.write '</li></ul>'}
  format.xml{response.write '</root>'}
end

get :home do
  format.html{response.write 'hello'}
end

map 'contact' do
  get do
    format.html{response.write 'contact someone today.'}
  end
  get ':person' do
    format.html {response.write "contact #{local_params[:person]}"}
    format.xml  {response.write "<node>Contact #{local_params[:person]}</node>"}
    format.json {response.write '{}'}
  end
end