gem 'dm-core'
require 'dm-core'

DataMapper.setup(:default, 'sqlite3::memory:')

class Post
  include DataMapper::Resource
  property :id,         Integer, :serial => true
  property :title,      String
  property :body,       Text
  property :created_at, DateTime
  has n, :comments
end

class Comment
  include DataMapper::Resource
  property :id,         Integer, :serial => true
  property :posted_by,  String
  property :email,      String
  property :url,        String
  property :body,       Text
  belongs_to :post
end

class Category
  include DataMapper::Resource
  property :id,         Integer, :serial => true
  property :name,       String
end

class Categorization
  include DataMapper::Resource
  property :id,         Integer, :serial => true

  property :created_at, DateTime

  belongs_to :category
  belongs_to :post
end

# Now we re-open our Post and Categories classes to define associations

class Post
  has n, :categorizations
  has n, :categories, :through => :categorizations
end

class Category
  has n, :categorizations
  has n, :posts,      :through => :categorizations
end

DataMapper.auto_migrate!