module Snap::Context::Actions
  
  #
  #
  #
  def index(options={}, &block)
    get(options, &block)
  end
  
  #
  #
  #
  def create(options={}, &block)
    put(options, &block)
  end
  
  #
  #
  #
  def new(options={}, &block)
    map(:new) do
      get(options, &block)
    end
  end
  
  #
  #
  #
  def show(pattern=:digit, options={}, &block)
    map(pattern) do
      get(options, &block)
    end
  end
  
  #
  #
  #
  def update(pattern=:digit, options={}, &block)
    map(pattern) do
      put(options, &block)
    end
  end
  
  #
  #
  #
  def delete(pattern=:digit, options={}, &block)
    map(pattern) do
      delete(options, &block)
    end
  end
  
  #
  #
  #
  def edit(pattern={:id=>:digit}, options={}, &block)
    map(pattern) do
      map(:edit) do
       get(options, &block)
      end
    end
  end
  
end