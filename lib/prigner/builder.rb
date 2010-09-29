class Prigner::Builder

  require "fileutils"

  include FileUtils

  attr_reader :project

  attr_reader :template

  def initialize(project, template)
    @project, @template = project, template
  end

  def make_project_path
    mkdir_p(@project.path)
    yield [ @project.path, File.exist?(@project.path) ]
  end

  def make_project_directories
    @template.directories.collect do |basedir|
      directory = basedir.gsub(/\((.*?)\)/){ @project.send($1) }
      path      = File.join(@project.path, directory)
      mkdir_p(path)
      yield [ path, File.exist?(path) ]
    end
  end

  def make_project_files
    @template.models.map do |model, basename|
      file = basename.gsub(/\((.*?)\)/){ project.send($1) }
      path = File.join(@project.path, file)
      model.binder = Prigner::Binder.new(@project, @template.options)
      model.write(path)
      yield [ model.file_written, File.exist?(model.file_written) ]
    end
  end

end

