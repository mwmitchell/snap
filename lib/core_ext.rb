class Symbol
  def to_proc
    proc { |obj, *args| obj.send(self, *args) }
  end
end

class Proc
  
  def source
    self.to_s.scan(/@(.*)>/)
  end
  
end

class String
  
  # Converts +self+ to an escaped URI parameter value
  #   'Foo Bar'.to_param # => 'Foo%20Bar'
  def to_param
    URI.escape(self)
  end
  
  # Converts +self+ from an escaped URI parameter value
  #   'Foo%20Bar'.from_param # => 'Foo Bar'
  def from_param
    URI.unescape(self)
  end
  
  #
  # :trim and :trim!
  # Similar to PHP's trim function
  # Aceepts multiple arguments for characters to trim
  # from the beginning of the string and the end
  #
	%W(trim trim!).each do |m|
	  define_method m do |*args|
	    raise 'Characters argument missing' unless (chars=args.join(' '))
	    p = [/^[#{Regexp.escape(chars)}]+|[#{Regexp.escape(chars)}]+$/, '']
	    m[-1..-1] == '!' ? self.gsub!(*p) : self.gsub(*p)
	  end
	end
  
  #
  # Removes duplicate instances of characters
  #
	%W(dedup dedup!).each do |m|
	  define_method m do |*args|
	    raise 'Character argument missing' if args.nil?
	    value=self
	    args.each do |char|
	      p = [/#{Regexp.escape(char)}+/, char]
	      m[-1..-1] == '!' ? self.gsub!(*p) : (value = value.gsub(*p))
	    end
	    value
	  end
	end

	#
	# removes starting and ending instances of the characters argument (calls :trim)
	# replaces sets of duplicated characters with a single character (calls :dedup)
	# 
	# puts 'testtktu'.cleanup('t', 'u') == 'estk'
	# 
	%W(cleanup cleanup!).each do |m|
	  define_method m do |*args|
	    m[-1..-1] == '!' ? (trim!(*args) && dedup!(*args)) : (trim(*args).dedup(*args))
	  end
	end

end

class Hash
  
  def deep_merge(hash)
    target = dup
    hash.keys.each do |key|
      if hash[key].is_a? Hash and self[key].is_a? Hash
        target[key] = target[key].deep_merge(hash[key])
        next
      end
      target[key] = hash[key]
    end
    target
  end
  
  def deep_merge!(second)
    second.each_pair do |k,v|
      if self[k].is_a?(Hash) and second[k].is_a?(Hash)
        self[k].deep_merge!(second[k])
      else
        self[k] = second[k]
      end
    end
  end
  
  def to_params
    map { |k,v| "#{k}=#{URI.escape(v)}" }.join('&')
  end

  def symbolize_keys
    self.inject({}) { |h,(k,v)| h[k.to_sym] = v; h }
  end

  def pass(*keys)
    reject { |k,v| !keys.include?(k) }
  end

end