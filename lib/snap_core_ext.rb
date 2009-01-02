class Symbol
  # Turns the symbol into a simple proc, which is especially useful for enumerations. 
  def to_proc
    Proc.new { |*args| args.shift.__send__(self, *args) }
  end
end

class String
  
  def /(next_path_fragment)
    next_path_fragment.empty? ? self : [self, next_path_fragment].join('/')
  end
  
end

class Hash
  
  # @param *allowed<Array[(String, Symbol)]> The hash keys to include.
  #
  # @return <Hash> A new hash with only the selected keys.
  #
  # @example
  # { :one => 1, :two => 2, :three => 3 }.only(:one)
  # #=> { :one => 1 }
  def only(*allowed)
    hash = {}
    allowed.each {|k| hash[k] = self[k] if self.has_key?(k) }
    hash
  end
  
  # @param *rejected<Array[(String, Symbol)] The hash keys to exclude.
  #
  # @return <Hash> A new hash without the selected keys.
  #
  # @example
  # { :one => 1, :two => 2, :three => 3 }.except(:one)
  # #=> { :two => 2, :three => 3 }
  def except(*rejected)
    hash = self.dup
    rejected.each {|k| hash.delete(k) }
    hash
  end
  
end