module Blog::Controllers
  
  class Posts
    
    extend Snap::App
    
    use Snap::HttpAuth, :user=>'admin', :pass=>'v9j33f-'
    
    extend Snap::Context::Actions
    
    # GET /
    index do
      @posts=Post.find(:all, :limit=>10)
      render
    end
    
    # POST /
    create do
      @post=Post.create(params[:post])
      redirect if @post.valid?
    end
    
    # GET /new
    new do
      render
    end
    
    # GET /:id/edit
    edit do

    end
    
    # GET /:id
    show do
      render 'posts/show'
    end
    
    # PUT /:id
    update do
      # update
    end
    
    # DELETE /:id
    delete do
      # delete
    end
  end
  
end