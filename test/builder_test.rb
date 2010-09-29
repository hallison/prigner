require "test/unit"
require "test/helpers"
require "prigner"

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
    @builder.make_project_path do |path, status|
      assert status, "Project path #{path} not created"
    end
  end

  should "create project directories" do
    @builder.make_project_directories do |directory, status|
      assert status, "Directory #{directory} not created"
    end
  end

  should "create project files" do
    @builder.make_project_files do |file, status|
      assert status, "File #{file} not created"
    end
  end

end

