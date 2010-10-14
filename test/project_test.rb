require "test/unit"
require "test/helpers"
require "lib/prigner"

class ProjectTest < Test::Unit::TestCase

  def setup
    @project = Prigner::Project.new("#{FIXTURES}/project/ruby-tagger")
  end

  should "check basic attributes of project" do
    assert_equal "#{FIXTURES}/project/ruby-tagger", @project.path
    assert_equal "ruby-tagger", @project.name
  end

  should "split name" do
    assert_equal %w{ruby tagger}, @project.name_splited
  end

  should "naming to upper camel case" do
    assert_equal "RubyTagger", @project.upper_camel_case_name
    assert_equal "rubyTagger", @project.lower_camel_case_name
  end

  should "naming to namespace with upper camel case" do
    assert_equal "Ruby::Tagger", @project.upper_camel_case_namespace("::")
    assert_equal "Ruby.Tagger",  @project.upper_camel_case_namespace(".")
  end

  should "naming to namespace with lower camel case" do
    assert_equal "ruby::Tagger", @project.lower_camel_case_namespace("::")
    assert_equal "ruby.Tagger",  @project.lower_camel_case_namespace(".")
  end

  should "naming to namespace with upper case" do
    assert_equal "RUBY::TAGGER", @project.upper_case_namespace("::")
    assert_equal "RUBY.TAGGER",  @project.upper_case_namespace(".")
  end
  
  should "naming to namespace with lower case" do
    assert_equal "ruby::tagger", @project.lower_case_namespace("::")
    assert_equal "ruby.tagger",  @project.lower_case_namespace(".")
  end

end

