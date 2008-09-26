class Snap::Zone::Action < Snap::Zone::Event::Base
  
  attr_reader :request_method, :full_name, :name, :path, :full_path
  
  def initialize(zone, request_method, input_path='', options={}, &block)
    @request_method=request_method
    @name, @path = Snap::Zone::Base.resolve_name_and_path(input_path)
    @full_name = zone.nil? ? @name : [zone.full_name, @name].reject{|v|v.to_s.empty?}.join('/')
    super zone, options, &block
  end
  
  def local_values
    @local_values||[]
  end
  
  def local_params
    @local_params||={}
  end
  
  def match?(method, input_path)
    # must set full path here... if this is a "use", then the zone won't be known until now
    @full_path||=[zone.full_path, path].join('/').cleanup('/')
    # methods much match
    return unless method==@request_method
    # return if exact match
    return true if input_path==@full_path
    # check simple aliases
    return true if @options[:alias] and @options[:alias].to_a.any?{|a|a==input_path}
    # if @full_path is empty at this point it's clearly not match
    return if @full_path.empty?
    # break up the input path into path fragments
    input_fragments=input_path.cleanup('/').split('/')
    # break up this actions full_path into path fragments
    path_fragments=@full_path.split('/')
    # if the sizes don't match, then the paths don't match
    return if path_fragments.size!=input_fragments.size
    # offset for param index
    offset=0
    # move through each self.full_path fragment
    path_fragments.each_with_index do |p,index|
      # if it's a param
      if p[0..0] == ':'
        # get the name of the param
        param=p[1..-1].to_sym
        # if there isn't a rule, setup a default rule
        regexp = @options[:rules][param] rescue /^\w+$/
        # if there is a match, increment the offset and save the value using the current param as the key
        if regexp.match(input_fragments[index])
          offset+=1
          local_values << local_params[param] = input_fragments[index]
        end
      # here there is a static/exact match - no param
      elsif p == input_fragments[index]
        local_values << input_fragments[index]
        offset+=1
      end
    end
    # if there are still params after the new offset, then this isn't the right handler
    return if input_fragments[offset..-1].size>0
    # merge the path params with the params set in the options when this action was defined
    local_params.merge!(@options[:params]) if @options[:params]
    true
  end
  
  def execute
    @zone.execute_before_filters(self)
    response.write super
    @zone.execute_after_filters(self)
  end
  
end