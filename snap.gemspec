spec=Gem::Specification.new do |s|
  s.name = "snap"
  s.version = '0.5.0'
  s.date = "2008-06-21"
  s.summary = "Snap is a Ruby, DSL based framework for creating RESTful web applications."
  s.email = "goodieboy@gmail.com"
  s.homepage = "http://github.com/mwmitchell/snap"
  s.description = s.summary
  s.has_rdoc = true
  s.author = 'Matt Mitchell'
  s.files = %W(
    README
    LICENSE
    CHANGES
    examples/demo.rb
    lib/snap.rb
    lib/snap/app.rb
    lib/snap/context.rb
    lib/snap/demo.rb
    lib/snap/request.rb
    lib/snap/context/base.rb
    lib/snap/context/events.rb
    lib/snap/context/matcher.rb
  )
  s.test_files = []
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ['README', 'LICENSE']
  s.add_dependency("rack", ["0.3.0"])
end