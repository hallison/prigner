# This class is a simple implementation of a directory tree using the Pathname
# class from Ruby Standard Library.
class Rubify::Project < ::Pathname

  # Project name.
  attr_reader :name

  # Project files.
  attr_reader :files

  # Initialize a new project directory path.
  def initialize(path)
    super(path)
    @name  = File.basename(path)
    @files = {}
    mkpath
    yield self if block_given?
  end

  # Create a file in the tree of project.
  def <<(file)
    @files[file] = self + file
    @files[file].dirname.mkpath
    @files[file].open("w+").write("") unless @files[file].exist?
    self
  end

  # Creates and open a file in the tree of project.
  def file(file, &block)
    self << file unless @files[file]
    @files[file].open("w+", &block)
  end

  # Open a file in tree of project.
  def [](file)
    @files[file]
  end

end # class Rubify::Project

