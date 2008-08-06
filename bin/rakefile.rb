def options
  a=ARGV.clone
  a.shift
  a
end

def out(message)
  puts "-- #{message}"
end

namespace :generate do
  
  desc "Creates a simple, Rackified Snap application: snap generator:app ./path/to/app"
  task :app do
    base_dir = options[0] rescue './'
    mkdir base_dir
    Dir['../generator/app/*'].each do |e|
      cp e, base_dir
    end
  end
  
end