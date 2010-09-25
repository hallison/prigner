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
    return new(all[namespace.to_s][template.to_s])
  end

  # Look at user home and template shared path.
  def self.shared_path
    [ File.join(user_home, ".prigner"), "#{Prigner::ROOT}/share" ]
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

  def self.all
    namespaces = {}
    shared_path.map do |share|
      Dir["#{share}/*/*"].sort.map do |path|
        template  = File.basename(path)
        namespace = File.basename(File.dirname(path))
        namespaces[namespace] ||= {}
        namespaces[namespace][template] = path
      end
    end
    namespaces
  end

  # This method draw project structure. Basically, creates the project path and all
  # directories and draws all models to destination files.
  def draw(path)
    require "fileutils"
    sys     = FileUtils
    project = Prigner::Project.new(path)
    workdir = sys.pwd

    sys.mkdir_p(project.path)
    sys.chdir(project.path)

    directories_for project do |directory|
      sys.mkdir_p directory
    end

    models_for project do |model, file|
      model.write file
    end

    sys.chdir(workdir)
  end

  private

  # Return the specfile placed in template path.
  def specfile
    Dir["#{@path}/[Ss]pecfile"].first
  end

  def initialize_specfile
    @spec = Prigner::Spec.load(specfile) if specfile
  end

  def initialize_options
    @options = @spec.options.inject({}) do |options, (name, desc)|
      options[name] = { :enabled => nil, :description => desc }
      options
    end.to_struct
  end

  def initialize_directories
    @directories = @spec.directories
  end

  def initialize_models
    @models = @spec.files.inject({}) do |models, (model, file)|
      models["#{@path}/models/#{model}"] = file ? file : "#{@path}/#{model}"
      models
    end
  end

  def directories_for(project, &block)
    @directories.collect do |directory|
      directory.gsub!(/\((.*?)\)/) do
        "#{project.send($1)}"
      end
    end
    @directories.map(&block)
  end

  def models_for(project, &block)
    @models = @models.inject({}) do |hash, (source, file)|
      file.gsub!(/\((.*?)\)/) do
        project.send($1)
      end
      bind  = Prigner::Bind.new(project, @options)
      model = Prigner::Model.new(source, bind)
      hash[model] = File.join(project.path, file)
      hash
    end
    @models.map(&block)
  end

end

