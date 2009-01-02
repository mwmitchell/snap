require 'rubygems'
require 'rack'

proc {|base, files|
  $: << base unless $:.include?(base) || $:.include?(File.expand_path(base))
  files.each {|f| require f}
}.call(File.dirname(__FILE__), ['snap_core_ext'])

module Snap
  
  autoload :App, 'snap/app'
  autoload :Dispatcher, 'snap/dispatcher'
  autoload :Rack, 'snap/rack'
  autoload :Router, 'snap/router'
  
  class << self
    attr_accessor :env, :root, :default_config, :config_blocks
  end
  
  @env = :development
  @root = File.expand_path('.')
  @default_config = {
    :view_paths => [Snap.root / 'views']
  }
  @config_blocks = {}
  
  def self.configure(env=:all, &blk)
    @config_blocks[env] = blk
  end
  
  def self.config
    @config ||= (
      def_config = @default_config.dup
      e = Snap.env.to_sym
      @config_blocks[:all].call(def_config) if @config_blocks[:all]
      @config_blocks[e].call(def_config) if e
      def_config
    )
  end
  
end