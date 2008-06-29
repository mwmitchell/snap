$:.unshift File.join(File.dirname(__FILE__), '..') unless
  $:.include?(File.join(File.dirname(__FILE__), '..')) or $:.include?(File.expand_path(File.join(File.dirname(__FILE__), '..')))

require 'rubygems'

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'lib', 'snap'))

SNAP_ROOT=File.expand_path(File.join(File.dirname(__FILE__)))
def app_path(*args); File.join(SNAP_ROOT, *args) end

#app.class.root.instance_eval do
  #File.read './app.rb'
  #use Snap::Renderer::Erb, :base_dir=>app_path('templates')
  #use TemplateWrapper, :exclude=>[:posts]
  #include Models
  #include Controllers
#end

#use Rack::Auth::Basic do |username, password|
#  'secret' == password
#end

def snap!
  o = Object.new
  o.instance_eval do
    def call(env)
      app=Snap::App::Base.new
      # Snap::Config is responsible for providing config settings and transparently switching between :modes
      app.config=Snap::Config.new(Snap::HashBlock.load_from_file('config/config.rb').to_hash, :development)
      app.class.map{instance_eval File.read('app.rb')}
      app.call(env)
    end
  end
  o
end