$:.unshift File.join(File.dirname(__FILE__))
$:.unshift File.join(File.dirname(__FILE__), 'lib')

require 'snap'

require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'

task :default=>[:spec]

desc 'Run all specs'
task :spec do
  Dir['spec/*.spec.rb'].each do |f|
    puts "Running #{f}"
    require f
  end
end