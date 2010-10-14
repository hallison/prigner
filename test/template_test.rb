require "test/unit"
require "test/helpers"
require "lib/prigner"

class Prigner::Template
  def self.shared_path
    [ "#{FIXTURES}/templates/user",
      "#{FIXTURES}/templates/shared" ]
  end
end

class TemplateTest < Test::Unit::TestCase

  def setup
    @options = {
      :svn => "Include Subversion keywords in code.",
      :git => "Enable Git flags in templates."
    }
    @path         = "#{FIXTURES}/templates/shared/ruby/default"
    @project_path = "#{FIXTURES}/project/foo"
    @template     = Prigner::Template.new(@path)
  end

  def teardown
    FileUtils.remove_dir @project_path if File.exist? @project_path
  end

  should "load basic attributes from directory name" do
    assert_equal "ruby", @template.namespace
    assert_equal "default", @template.name
  end

  should "load options" do
    @options.keys.each do |option|
      assert_equal @options[option], @template.options[option].description
    end
  end

  should "disable all options by default" do
    @options.keys.each do |option|
      assert !@template.options[option].enabled
    end
  end

  should "load a template using namespace" do
    template = Prigner::Template.load(:ruby)
    assert_equal @path, template.path.to_s
    assert_equal "ruby", template.namespace
    assert_equal "default", template.name
  end

  should "load a template looking home user directory" do
    ENV['HOME'] = "#{FIXTURES}/templates/user"
    template = Prigner::Template.load(:ruby, :program)
    assert_equal "ruby", template.namespace
    assert_equal "program", template.name
  end

  should "check number of models and directories" do
    assert_equal 2, @template.directories.size
    assert_equal 3, @template.models.size, "Models size not matched"
  end

  should "list all template paths from shared path" do
    assert_equal 6, Prigner::Template.all_template_paths.size
  end

  should "list all templates grouped by namespace" do
    assert_equal 3, Prigner::Template.all.keys.size
    assert_equal 1, Prigner::Template.all["bash"].size
    assert_equal 2, Prigner::Template.all["ruby"].size
    assert_equal 3, Prigner::Template.all["vim"].size
  end

  should "raise runtime error when specfile not found" do
    assert_raises RuntimeError do
      Prigner::Template.new("not/exist")
    end
  end

  should "raise runtime error when nil values to namespace and/or template" do
    assert_raises RuntimeError do
      Prigner::Template.load(nil, nil)
    end
  end

end

