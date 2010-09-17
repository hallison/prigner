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

  SHARED_PATH = [ "#{ENV['HOME']}/.Prigner", "#{Prigner::ROOT}/share" ]

  # Namespace of template.
  attr_reader :namespace

  # Name of template.
  attr_reader :name

  # List of models.
  attr_reader :models

  # List of directories that will created in project tree.
  attr_reader :directories

  # List of options (see Spec::options).
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

  # Load template from SHARED_PATH. The SHARED_PATH set the home user directory
  # and Prigner::Template shared files.
  def self.load(namespace, template = :default)
    SHARED_PATH.map do |source|
      path = "#{source}/#{namespace}/#{template}"
      return new(path) if File.exist? path
    end
  end

  # This method draw project structure. Basically, creates the project path and all
  # directories and draws all models to destination files.
  def draw(project, &block) #:yield: project
    project.path.mkpath
    pwd = Dir.pwd
    Dir.chdir(project.path)

    create_paths project do |basepath|
      @directories.collect do |directory|
        directory.gsub! /\((.*?)\)/ do
          project.instance_eval($1, specfile, 1)
        end
        basepath.join(directory).mkpath
      end
    end

    #models.collect do |model|
    #  model.draw model.chpath() do |file|
    #    model.file
    #  end
    #end
    yield project
    Dir.chdir(pwd)
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
      models[Prigner::Model.new("#{@path}/models/#{model}")] = file ? file : File.basename(model, ".erb")
      models
    end
  end
end

