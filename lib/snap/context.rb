#
# The "Context" is essentially the current request
#
module Snap::Context
  
  # these will be accessable thru Snap::Context
  M=%W(request response config)
  
  # class instance attributes (ex. Snap::Context.config etc.)
  class << self
    M.each{|meth| attr_accessor meth}
  end
  
  # This makes the above methods available to the classes that "include Snap::Context"
  M.each do |meth|
    class_eval <<-EOF
      def #{meth}(*args)
        Snap::Context.send(:#{meth}, *args)
      end
    EOF
  end
  
end