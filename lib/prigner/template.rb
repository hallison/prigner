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

  # Initialize a template using a path.
  #
  # Example:
  #
  #   template = Prigner::Template.new "path/to/template"
  #
  # The template initialization will search the +specfile+ in path passed as
  # argument (<tt>path/to/template/specfile</tt>) for Spec attributes.
  def initialize(path)
    @path      = Pathname.new(path)
    @namespace = @path.parent.basename.to_s
    @name      = @path.basename.to_s
    initialize_specfile
    initialize_options
    initialize_directories
    initialize_models
  end

  # Load template from shared directories. The shared path set the home user
  # directory and Prigner::Template shared files.
  def self.load(namespace, template = :default)
    shared_path.map do |source|
      path = "#{source}/#{namespace}/#{template}"
      return new(path) if File.exist? path
    end
  end

  # Look at user home and template shared path.
  def self.shared_path
    user_home_templates = File.join(user_home_basedir, "templates")
    [ user_home_templates, "#{Prigner::ROOT}/share" ]
  end

  # User home.
  def self.user_home
    File.expand_path "~"
  rescue
    if File::ALT_SEPARATOR then
      "C:/"
    else
      "/"
    end
  end

  # User home base directory for Prigner files.
  def self.user_home_basedir
    File.join(user_home, ".prigner")
  end

  # Return all template paths placed in shared user or in project base
  # directory.
  def self.all_template_paths
    shared_path.map do |source|
      Dir.glob("#{source}/*/*")
    end.flatten.compact
  end

  # All templates grouped by namespace.
  def self.all
    all_template_paths.map do |path|
      new(path)
    end.inject({}) do |group, template|
      group[template.namespace] ||= []
      group[template.namespace] << template
      group
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
  rescue Exception => error
    raise RuntimeError, "No specfile in #{@path}."
  end

  # Initialize options.
  def initialize_options
    @options = @spec.options.inject({}) do |options, (name, desc)|
      options[name] = { :enabled => nil, :description => desc }
      options
    end.to_struct if @spec.options
  end

  def initialize_directories
    @directories = @spec.directories
  end

  def initialize_models
    @models = @spec.files.inject({}) do |models, (source, file)|
      model = Prigner::Model.new(@path.join("models", source))
      models[model] = file ? file : source
      models
    end if @spec.files
  end

end

