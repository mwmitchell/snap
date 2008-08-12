extend Snap::Renderers::Erubis

after do
  format.html do
    render 'shared/layout', :content=>response.body
  end
end

get do
  format.html{render 'pages/index'}
end

get :assets=>'assets' do
  format.js do
    
  end
  format.css do
    
  end
end

map :posts=>'posts' do
  
  get do
    format.xml{@posts.to_xml}
    format.html{render 'pages/posts/index'}
  end
  
  post do
    @post=Post.create(params[:post])
    flash('Create Successful!', path(:posts, @post.id)) if @post.valid?
    context.call :get, 'new'
  end
  
  get 'new' do
    @post=Post.new
    render 'pages/posts/new'
  end
  
  map ':post_id' do
    map 'comments', :load=>'comments'
    before { @post=Post.get(params[:post_id]) }
    get do
      format.xml{@post.to_xml}
      format.html{render 'pages/posts/show'}
    end
    get 'edit' do
      render 'pages/posts/edit'
    end
    put do
      @post.update_attributes params[:post]
      flash('Update Successful!', path(:posts, @post.id)) if @post.valid?
      context.call :get, @post.id, 'edit'
    end
    delete do
      flash('Delete Successful!', path(:posts)) if @post.delete
    end
  end
  
end