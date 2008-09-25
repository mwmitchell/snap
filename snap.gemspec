spec=Gem::Specification.new do |s|
  s.name = "snap"
  s.version = '0.6.0'
  s.date = "2008-08-06"
  s.summary = "Snap - a minimalist framework for creating RESTful web applications"
  s.email = "goodieboy@gmail.com"
  s.homepage = "http://github.com/mwmitchell/snap"
  s.description = s.summary
  s.has_rdoc = true
  s.author = 'Matt Mitchell'
  s.files = %W(
README
LICENSE
bin/snap
lib/core_ext.rb
lib/snap.rb
lib/snap/action.rb
lib/snap/context/action_methods.rb
lib/snap/context/hooks.rb
lib/snap/context.rb
lib/snap/event.rb
lib/snap/loader.rb
lib/snap/negotiator.rb
lib/snap/rack_runner.rb
lib/snap/renderers.rb
lib/snap/request.rb
lib/snap/response_helpers.rb
)
  s.require_paths = ['lib']
  s.test_files = []
  s.rdoc_options = ['--main', 'README']
  s.extra_rdoc_files = ['README', 'LICENSE']
  s.add_dependency('rack', ['0.4.0'])
end