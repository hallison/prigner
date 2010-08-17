# This class implements several methods for load a model file of template.
class Rubify::Model < ::Pathname

  attr_reader :content

  attr_reader :bind

  def initialize(path, binds = {})
    super(path)
    self.bind = binds
  end

  def bind=(hash)
    @bind = hash.to_struct
  end

  def build!
    require "erb"
    @content = ::ERB.new(self.read).result(bind.binding)
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

