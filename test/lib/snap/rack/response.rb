class Snap::Rack::Response < Rack::Response
  
  def headers=(headers={})
    headers.each do |k,v|
      self[k]=v
    end
  end
  
end