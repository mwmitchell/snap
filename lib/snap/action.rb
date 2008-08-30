class Snap::Action < Snap::Event::Base
  
  attr_reader :context, :request_method, :name, :path, :options, :block, :full_path
  
  def initialize(context, request_method, path='', options={}, &block)
    @request_method=request_method
    @name=nil
    @path=path
    if path.is_a?(Hash)
      @name,@path=path.keys.first,path.values.first
    elsif path.is_a?(Symbol)
      @name,@path=path,''
    end
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
    input_fragments=input_path.cleanup('/').split('/')
    path_fragments=@full_path.split('/')
    return if path_fragments.size!=input_fragments.size
    offset=0
    path_fragments.each_with_index do |p,index|
      if p[0..0] == ':'
        param=p[1..-1].to_sym
        regexp = @options[:rules][param] rescue /^\w+$/
        if regexp.match(input_fragments[index])
          offset+=1
          local_values << local_params[param] = input_fragments[index]
        end
      elsif p == input_fragments[index]
        local_values << input_fragments[index]
        offset+=1
      end
    end
    # if there are still params after the new offset, then this isn't the right handler
    return if input_fragments[offset..-1].size>0
    local_params.merge!(@options[:params]) if @options[:params]
    true
  end
  
  def request
    @context.request
  end
  
  def response
    @context.response
  end
  
  def method_missing(m,*args,&block)
    context.send(m, *args, &block)
  end
  
  def execute
    content = context.execute_before_and_after_blocks(self) do
      result = super(request, response)
      if @formatter
        format_block=@formatter.resolve(request.format)
        result = instance_eval &format_block if format_block
      end
      result
    end
    return content.inspect
  end
  
end