spec=Gem::Specification.new do |s|
  s.name = "snap"
  s.version = '0.3.0'
  s.date = "2008-06-11"
  s.summary = "Snap is a Ruby, DSL based framework for creating RESTful web applications. It adheres to the Ruby Rack specification."
  s.email = "goodieboy@gmail.com"
  s.homepage = "http://github.com/mwmitchell/snap"
  s.description = s.summary
  s.has_rdoc = true
  s.author = 'Matt Mitchell'
  s.files = ['lib/snap.rb', 'lib/snap/demo.rb']
  s.test_files = ['spec/common.rb', 'spec/demo.spec.rb', 'spec/request.spec.rb']
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ['README', 'LICENSE']
  s.add_dependency("rack", ["0.3.0"])
end