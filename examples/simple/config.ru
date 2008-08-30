require '../../lib/snap.rb'

run Snap::Initializer.new { |config|
  config.view_paths << 'app/views'
}