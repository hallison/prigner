# == Model
#
# This class implements several methods for load a model file of template.
# 
# Basically behaviour as parser based in a ERB file placed in +models+
# directory of a Template.
#
# Example:
#
#   # model: jedi/knight
#   class <%=name.capitalize%>
#   <%for attribute in attributes%>
#     attr_accessor :<%=attribute%>
#   <%end%>
#     def initialize(<%=attributes.join(",")%>)
#     <%for attribute in attributes%>
#       @<%=attribute%> = <%attribute%>
#     <%end%>
#     end
#
#     def to_s
#     <%for attribute in attributes%>
#       "\n<%=attribute.capitalize%>: #{<%=attribute%>}"
#     <%end%>
#     end
#   end
#
#   <%=name%> = <%=name.capitalize%>.new("Yoda", "Jedi Grand Master")
#   # end model
#
#   $> model = Pringer::Model.new "jedi/knight", {
#        :name       => "knight",
#        :attributes => [ :name, :position ]
#      }
#   $> model.build!
#   $> model.contents
#   => class Knight
#   => 
#   =>   attr_accessor :name
#   =>   attr_accessor :position
#   => 
#   =>   def initialize(name,position)
#   =>
#   =>     @name = name
#   =>     @position = position
#   =>
#   =>   end
#   =>
#   =>   def to_s
#   =>
#   =>     "\nName: #{name}"
#   =>     "\nPosition: #{position}"
#   =>
#   =>   end
#   => end
#   =>
#   => knight = Knight.new("Yoda", "Jedi Grand Master")
#
class Prigner::Model

  # Model path file.
  attr_reader :path

  # Parsed contents.
  attr_reader :contents

  # Value bindings.
  attr_reader :bind

  # Result file written
  attr_reader :file_written

  # Initializes a model passing all attributes by Hash.
  def initialize(path, bind = {})
    @path = Pathname.new(path)
    @bind = (bind.kind_of? Hash) ? bind.to_struct : bind
  end

  # Build model contents.
  def build!
    require "erb"
    @contents = ::ERB.new(@path.read).result(bind.binding)
  end

  # Write contents into file.
  def write(file)
    @file_written = file
    file = file.to_path
    file.dirname.mkpath
    file.open "w+" do |output|
      output << self.build!
    end
    self
  end

end

