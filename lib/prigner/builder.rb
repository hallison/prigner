# == The project builder
#
# The Builder class is a main handler of the projects and templates.
class Prigner::Builder

  require "fileutils"

  include FileUtils

  attr_reader :project

  attr_reader :template

  # Build a new project based on a template.
  def initialize(project, template)
    @project, @template = project, template
  end

  def make_project_path #:yields: path, info
    mkdir_p(@project.path)
    { no_pwd(@project.path) => File.stat(@project.path) }
  end

  def make_project_directories #:yields: path, info
    @template.directories.inject({}) do |hash, basedir|
      directory = basedir.gsub(/\((.*?)\)/){ @project.send($1) }
      path      = File.join(@project.path, directory)
      mkdir_p(path)
      hash[no_pwd(path)] = File.stat(path)
      hash
    end
  end

  def make_project_files(option = :required) #:yields: path, info
    @template.models[option.to_sym].inject({}) do |hash, (model, basename)|
      file = basename.gsub(/\((.*?)\)/){ project.send($1) }
      path = File.join(@project.path, file)
      model.binder = Prigner::Binder.new(@project, @template.options)
      model.write(path)
      hash[no_pwd(model.file_written)] = File.stat(model.file_written)
      hash
    end if @template.models.has_key?(option.to_sym)
  end

  def make_project_files_for_option(option)
    @template.initialize_models_for_option(option)
    self.make_project_files(option)
  end

private

  def no_pwd(path)
    path.gsub("#{Dir.pwd}/", "")
  end
end

