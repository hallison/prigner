# This class implements several methods for load a model file of template.
class Prigner::Model

  attr_reader :path

  attr_reader :content

  attr_reader :bind

  def initialize(path, binds = {})
    @path = Pathname.new(path)
    self.bind = binds
  end

  def bind=(hash)
    @bind = hash.to_struct
  end

  def build!
    require "erb"
    @content = ::ERB.new(@path.read).result(bind.binding)
  end

  def draw(destination)
    file = destination.to_path
    file.dirname.mkpath
    file.open "w+" do |output|
      output << self.build!
    end
    self
  end

end

