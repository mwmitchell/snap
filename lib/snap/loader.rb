module Snap::Loader
  def load(file)
    instance_eval File.read(file)
  end
end