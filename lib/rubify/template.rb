# This class implements several methods for load a template file for a new
# Ruby project.
#
# This class implements several methods for load a template file for a new
# Ruby project. Basically, a template is based in an YAML file and a directory
# containing all files to be parsed. 

class Rubify::Template < ::Pathname

  attr_reader :models

  attr_reader :directories

  attr_reader :options

  attr_reader :name

  attr_reader :path

  def initialize(path)
    super(path)
    @name = File.basename(path)
    initialize_options_from(path)
    initialize_models_and_directories_from(path)
  end

  private

  def config_file
    "#{File.dirname(@path)}/#{File.basename(@path)}.yml"
  end

  def load_config
    YAML.load_file(config_file).symbolize_keys
  end

  def initialize_options_from(path)
    @options = load_config[:options].inject({}) do |options, (name, desc)|
      options[name] = { :enabled => false, :description => desc }
      options
    end.to_struct
  end

  def initialize_models_and_directories_from(path)
    @models, @directories = [], []
    Dir["#{path}/**/**"].collect do |path|
      @models      << Rubify::Model.new(path) if File.file? path
      @directories << path.to_path if File.directory? path
    end
  end
end

