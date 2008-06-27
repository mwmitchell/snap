$:.unshift File.join(File.dirname(__FILE__)) unless
  $:.include?(File.join(File.dirname(__FILE__))) or $:.include?(File.expand_path(File.join(File.dirname(__FILE__))))

require 'rubygems'
require 'snap'
require 'rack'

SNAP_ROOT=File.expand_path(File.join(File.dirname(__FILE__)))
def app_path(*args); File.join(SNAP_ROOT, *args) end

app=Snap::App::Base.new
app.mode=:development

# Snap::Config is responsible for providing config settings and transparently switching between :modes
app.config=Snap::Config.new(Snap::HashBlock.load_from_file('config.rb').to_hash, app.mode)

app.class.root.load_from_file('./app.rb') do
  use Snap::Renderer::Erb, :base_dir=>app_path('templates')
  use TemplateWrapper, :exclude=>[:posts]
  include Models
  include Controllers
end