=begin

# TEST

include Snap::Context::Matcher

puts true == options_match?({}, {:server_name=>'localhost'})

puts true ==options_match?({:server_name=>'localhost'}, {:server_name=>'localhost'})

puts true == options_match?({:server_name=>/local/}, {:server_name=>'localhost'})

puts false == options_match?({:server_name=>/k/}, {:server_name=>'localhost'})

puts false == options_match?({:asdasd=>'x', :localhost=>'localhost'}, {:server_name=>'localhost'})

puts true == options_match?({}, {:server_name=>'localhost', :port=>8080})

puts false == options_match?({:port=>9}, {:port=>8080})

=end

#
#
#
module Snap::Context::Matcher

  PATTERNS={
    :digit=>/^\d+$/,
    :word=>/^\w+$/
  }

  #
  # Checks the pattern against the value
  # The pattern can be a:
  #   * string - uses == to compare
  #   * regexp - uses =~ to compare
  #   * symbol - first looks up value in PATTERNS; if found, uses the PATTERN value; if not, converts to string
  #   * hash - assigns the value to the key within the params array if matches; the value can be any of the above
  #
  # ==Examples
  #   match?('hello', 'hello') == true
  #   match?(/h/, 'hello') == true
  #   match?(:digit, 1) == true - does a successfull lookup in PATTERNS
  #   match?(:admin, 'admin') == true - non-succesfull PATTERNS lookup, convert to string
  #   match?(:id=>:digit, 1) == true - also sets params[:id]=1
  #   match?(:name=>:word, 'sam') == true - sets params[:name]='sam'
  #   match?(:topic=>/^authors$|^publishers$/, 'publishers') - true - sets params[:topic]='publishers'
  #
  def match?(pattern, value)
    ok = simple_match?(pattern, value)
    return ok if ok
    # if hash, use the value as the pattern and set the request param[key] to the value argument
    return ({pattern.keys.first => match?(pattern[pattern.keys.first], value)}) if pattern.is_a?(Hash)
    # if symbol
    if pattern.is_a?(Symbol)
      # lookup the symbol in the PATTERNS hash
      if PATTERNS[pattern] and new_value=match?(PATTERNS[pattern], value)
        return new_value
      end
      # There was no match, convert to string
      simple_match?(pattern.to_s, value)
    end
  end

  #
  # Non-nested comparisons using == or =~
  #
  def simple_match?(pattern, value)
    # if regexp, regx comparison
    return value if (pattern.is_a?(Regexp) and value.to_s =~ pattern)
    # if string, simple comparison
    return value if (pattern.is_a?(String) and value.to_s == pattern)
  end
  
  #
  #
  #
  def options_match?(compare_from, compare_to)
    if compare_from.to_s.empty?
      return true
    end
    n={}
    compare_to.each_pair{ |k,v| n[k.to_s.downcase.gsub('-','_').gsub(' ', '').gsub('.', '_').to_sym]=v }
    matches=true
    compare_from.each_pair do |k,v|
      unless n.has_key?(k)
        matches=false
        break
      end
      unless match?(v,n[k]) or match?(v.to_s,n[k])
        matches=false
        break
      end
    end
    matches
  end
  
end