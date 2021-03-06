require "test/unit"
require "test/helpers"
require "lib/prigner"

def Prigner.shared_path
  [ "#{ENV['HOME']}/.prigner/templates",
    "#{FIXTURES}/templates/shared/templates" ]
end

class BuilderTest < Test::Unit::TestCase

  def setup
    @template = Prigner::Template.load(:ruby)
    @project  = Prigner::Project.new("#{FIXTURES}/project/duck")
    @builder  = Prigner::Builder.new(@project, @template)
  end

  def teardown
    FileUtils.remove_dir @project.path if File.exist? @project.path
  end

  should "create project path" do
    @builder.make_project_path.each do |path, status|
      assert status, "Project path #{path} not created"
    end
  end

  should "create project directories" do
    directories = @builder.make_project_directories
    directories.each do |directory, status|
      assert status, "Directory #{directory} not created"
    end
  end

  should "create project files" do
    files = @builder.make_project_files
    files.each do |file, status|
      assert status, "File #{file} not created"
    end
  end

  should "create optional files" do
    options = %w[bin test]
    options.each do |option|
      files = @builder.make_project_files_for_option(option)
      files.each do |file, status|
        assert status, "File #{file} not created"
      end
    end
  end

end

