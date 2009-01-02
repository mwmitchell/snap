# simple path router

#   params = Snap::Router.match?('path/from/request', 'my/route/:id', :rules=>{:id=>/\d+/}, :params=>{:default_param=>1}, :alias=>'something')
#   if params
#     # there was a match
#   else
#     # no match
#   end

class Snap::Router
  
  def self.match(input_path, route, options={})
    # remove leading/trailing slashes
    input_path = input_path.sub(/^\/+|\/$/, '')
    route = route.sub(/^\/+|\/$/, '')
    route_params = options[:params] || {}
    # return if exact match
    return route_params if input_path==route
    # check simple aliases
    return route_params if options[:alias] and options[:alias].to_a.any?{|a|a==input_path}
    # if route is empty at this point it's clearly not match
    return if route.empty?
    # break up the input path into path fragments
    input_path_fragments=input_path.squeeze('/').split('/')
    # break up this route into path fragments
    route_fragments=route.squeeze('/').split('/')
    # if the sizes don't match, then the paths won't match
    return if route_fragments.size != input_path_fragments.size
    # offset for param index
    offset=0
    # move through each route fragment
    route_fragments.each_with_index do |p,index|
      # if it's a param
      if p[0..0] == ':'
        # get the name of the param
        param=p[1..-1].to_sym
        # if there isn't a rule, setup a default rule
        regexp = options[:rules][param] rescue /^\w+$/
        # if there is a match, increment the offset and save the value using the current param as the key
        if regexp.match(input_path_fragments[index])
          offset+=1
          route_params[param] = input_path_fragments[index]
        end
      # here there is a static/exact match - no param
      elsif p == input_path_fragments[index]
        offset+=1
      end
    end
    # if there are still params after the new offset, then this isn't the right handler
    return if input_path_fragments[offset..-1].size > 0
    route_params
  end
  
end