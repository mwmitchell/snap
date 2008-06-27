class Snap::Request < Rack::Request
  
  def m
    request_method.to_s.downcase.to_sym
  end
  
  def path_info_slices
    ['/'] + path_info.to_s.gsub(/\/+/, '/').sub(/^\/|\/$/, '').split('/')
  end
  
end