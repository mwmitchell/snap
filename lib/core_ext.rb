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
 
  def trim(chars=' ')
    self.gsub(/^[#{chars}]+|[#{chars}]+$/, '')
  end
  
  def dedup(char)
    self.gsub(/#{char}+/, char)
  end
  
  def cleanup(char)
    trim(char).dedup(char)
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
  
end