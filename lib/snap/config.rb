module Snap::Config
  
  class << self
    attr_accessor :default_settings, :config_blocks
  end
  
  @default_settings = {
    :view_paths => [File.join(Snap.root, 'views')]
  }
  
  @config_blocks = {}
  
  def self.configure(env=:all, &blk)
    raise "This environment has already been configured: #{env}" if @config_blocks[env]
    @config_blocks[env] = blk
  end
  
  def self.config
    @config ||= (
      def_config = @default_settings.dup
      e = Snap.env.to_sym
      @config_blocks[:all].call(def_config) if @config_blocks[:all]
      @config_blocks[e].call(def_config) if e
      def_config
    )
  end
  
end