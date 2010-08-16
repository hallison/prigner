# This class implements several methods for load a template file for a new
# Ruby project.
#
# This class implements several methods for load a template file for a new
# Ruby project. Basically, a template is based in an YAML file and a directory
# containing all files to be parsed. 

class Rubify::Template < ::Pathname

  attr_reader :models

  attr_reader :result_path

  attr_reader :options

  def initialize(path)
    super(path)
    config = YAML.load_file("#{File.dirname(path)}/#{File.basename(path)}.yml").symbolize_keys
    @requirements = config[:requirements]
    @options      = config[:options].inject({}) do |options, (name, desc)|
      options[name] = { :enabled => false, :description => desc }
      options
    end.to_struct
  end

end

