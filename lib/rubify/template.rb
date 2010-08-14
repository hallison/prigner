# This class implements several methods for load a template file for a new
# Ruby project.
#
# This class implements several methods for load a template file for a new
# Ruby project. Basically, a template is based in an YAML file and a directory
# containing all files to be parsed. 

class Rubify::Template < ::Pathname

  attr_reader :result_file

  attr_reader :bind

  def initialize(path, binds = {})
    super(path)
    @result_file = self.to_s.gsub(self.extname, '').to_path
    @bind = binds.to_struct
    def @bind.binding
      super 
    end
  end

  def convert!
    @result_file.open "w+" do |file|
      require "erb"
      file << ::ERB.new(self.read).result(bind.binding)
    end
  end

end

