# == Project
#
# This class is a simple implementation of a tree of directories. It is used
# in model files.
class Prigner::Project

  # Project name.
  attr_reader :name

  alias project name

  # Project files.
  attr_reader :path

  # Project timestamp
  attr_reader :timestamp

  # Initialize a new project directory path.
  def initialize(path)
    @path = File.expand_path(path =~ /^\/.*/ ? path : "#{Dir.pwd}/#{path}")
    @name = File.basename(@path)
    @timestamp = DateTime.now
  end

  def name_splited
    @name.split(/[-_]/)
  end

  def namespace(joiner = "::")
    name_splited.join(joiner)
  end

  def upper_camel_case_namespace(joiner = "::")
    name_splited.map{ |str| str.capitalize }.join(joiner)
  end

  def lower_camel_case_namespace(joiner = "::")
    return name if name_splited.size == 0
    name_splited[1..-1].map do |str|
      str.capitalize
    end.unshift(name_splited.first).join(joiner)
  end

  def upper_case_namespace(joiner = "::")
    upper_camel_case_namespace(joiner).upcase
  end

  def lower_case_namespace(joiner = "::")
    upper_camel_case_namespace(joiner).downcase
  end

  def upper_camel_case_name
    upper_camel_case_namespace(nil)
  end

  alias class_name upper_camel_case_name

  def lower_camel_case_name
    lower_camel_case_namespace(nil)
  end

  def user
    Etc.getpwnam(Etc.getlogin)
  end

  def author
    self.user.gecos.split(",").first
  end

end # Project

