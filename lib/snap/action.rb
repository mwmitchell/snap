class Snap::Action < Snap::Event::Base
  
  attr_reader :context, :request_method, :name, :path, :options, :block, :full_path
  
  def initialize(context, request_method, input_path='', options={}, &block)
    @request_method=request_method
    @name=nil
    
    if input_path.class == String
      # standard, id-less action
      # get 'admin' do
      # ...
      # end
      @path = input_path
      puts "String! @name == #{@name} and @path == #{@path}"
    elsif input_path.class == Hash
      # for identifying an action:
      # get :admin=>'admin' do
      # ...
      # end
      @name, @path = input_path.keys.first, input_path.values.first
      puts "Hash! @name == #{@name} and @path == #{@path}"
    elsif input_path.class == Symbol
      # in case you want to identify an action, but not specify the blank path
      # get :home do
      # ...
      # end
      puts "Symbol! @name == #{@name} and @path == #{@path}"
      @name, @path = input_path, ''
    else
      puts "Something Else! @name == #{@name} and @path == #{@path}"
      @path=input_path.to_s
    end
    @path=URI.encode(@path.to_s)
    
    super context, options, &block
  end
  
  def local_values
    @local_values||[]
  end
  
  def local_params
    @local_params||={}
  end
  
  def match?(method, input_path)
    # must set full path here... if this is a "use", then the context won't be known until now
    @full_path||=[context.full_path, path].join('/').cleanup('/')
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
    @context.execute_before_filters(self)
    response.write super
    @context.execute_after_filters(self)
  end
  
end