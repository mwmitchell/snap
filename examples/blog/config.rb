sitename 'Blog 4U'
relative_root_url '/'
orm :activerecord

environments do
  
  development do
    reload_code true
    database do
      host :localhost
      database: :todo_development
      username ''
      password ''
    end
  end
  
  production do
    reload_code false
    database do
      host :localhost
      database: :todo_production
      username ''
      password ''
    end
  end
  
end