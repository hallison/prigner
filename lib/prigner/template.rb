# == Project Template
#
# This class implements several methods for load a template for a new project.
# Basically, a template is based in an YAML file for +specfile+ and a directory
# containing all files to be parsed. 
#
# The template tree is based in following structure:
#
#   namespace
#   `-- template
#       |-- models
#       `-- specfile
# 
# See Spec class for more information about mandatory attributes for draw your
# project using +specfile+.
class Prigner::Template

  Option = Struct.new(:enabled, :description, :files)

  # Namespace of template.
  attr_reader :namespace

  # Name of template.
  attr_reader :name

  # List of models.
  attr_reader :models

  # List of directories that will created in project tree.
  attr_reader :directories

  # List of options (see Spec#options).
  attr_reader :options

  # Path to template.
  attr_reader :path

  # Specifications
  attr_reader :spec

  # Initialize a template using a path.
  #
  # Example:
  #
  #   template = Prigner::Template.new "path/to/template"
  #
  # The template initialization will search the +specfile+ in path passed as
  # argument (<tt>path/to/template/specfile</tt>) for Spec attributes.
  def initialize(path)
    @path      = Pathname.new(path).tap{ |check| check.stat }
    @namespace = @path.parent.basename.to_s
    @name      = @path.basename.to_s
    initialize_specfile
    initialize_options
    initialize_directories
    initialize_models
  rescue Errno::ENOENT => error
    raise RuntimeError, error.message
  end

  # Mask for presentation of template.
  def mask
    @name == "default" ? @namespace : "#{@namespace}:#{@name}"
  end

  # Load template from shared directories. The shared path set the home user
  # directory and Prigner::Template shared files.
  def self.load(namespace, template = :default)
    Prigner.shared_path.map do |source|
      path = "#{source}/#{namespace}/#{template}"
      return new(path) if File.exist? path
    end
    nil
  end

  # Return all template paths placed in shared user or in project base
  # directory.
  def self.all_template_paths
    Prigner.shared_path.map do |source|
      Dir.glob("#{source}/*/*")
    end.flatten.compact
  end

  # All templates grouped by namespace.
  def self.all
    all_template_paths.map do |path|
      new(path)
    end.inject({}) do |group, template|
      customized = template.path.to_s =~ %r/#{Prigner.user_home_basedir}/
      group[template.namespace] ||= []
      group[template.namespace] << [ template, customized ]
      group
    end
  end

  # If the option has list of files, then initialize all models.
  def initialize_models_for_option(optname)
    option = optname.to_sym
    unless @options[option].files.empty?
      @models[option] = parse_models(@options[option].files)
    end
  end

  private

  # Return the specfile placed in template path.
  def specfile
    Dir["#{@path}/[Ss]pecfile"].first
  end

  # Load +specfile+ placed in template path.
  def initialize_specfile
    @spec = Prigner::Spec.load(specfile)
  end

  # The "+options+" attribute is a Hash that contains a list of the Option
  # structure.
  def initialize_options
    @options = @spec.options.inject({}) do |options, (name, params)|
      options[name] = Option.new
      options[name].enabled     = false
      options[name].description = params["description"] || params
      options[name].files       = params["files"]   || {}
      options
    end.to_struct if @spec.options
  end

  def initialize_directories
    @directories = @spec.directories || []
  end

  # All models are listed by a Hash and are indexed by "+required+" key and the
  # option names.
  def initialize_models
    @models = {}
    @models[:required] = parse_models(@spec.files) if @spec.files
  end

  # Parses a Hash that contains a pair of the model file name and the result
  # output name.
  def parse_models(hash)
    hash.inject({}) do |models, (source, file)|
      model = Prigner::Model.new(@path.join("models", source))
      models ||= {}
      models[model] = file ? file : source
      models
    end
  end

end

