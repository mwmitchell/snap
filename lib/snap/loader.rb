module Snap::Loader
  def load(file)
    begin
      instance_eval File.read(file)
    rescue
      raise "Error in #{file}: #{$!}"
    end
  end
end