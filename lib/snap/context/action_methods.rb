module Snap::Context
  module ActionMethods
    %W(get post put delete).each do |m|
      class_eval <<-EOF
        def #{m}(path='', options={}, &block)
          add_action :#{m}, path, options, &block
        end
      EOF
    end
  end
end