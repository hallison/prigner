BASE_PATH = "#{File.expand_path(File.dirname(__FILE__))}/.."

$LOAD_PATH.unshift(BASE_PATH) unless $LOAD_PATH.include? BASE_PATH

require "test/unit"
require "test/helpers"
require "lib/rubify"

class ProjectTest < Test::Unit::TestCase

  PATH = Pathname.new(BASE_PATH)

  def setup
    @project = Rubify::Project.new("test/fixtures/project/foo")
  end

  should "check basic attributes of project" do
    assert_equal "test/fixtures/project/foo", @project.to_s
    assert_equal "foo", @project.name
  end

  should "create a new file and add contents" do
    Rubify::Project.new "test/fixtures/project/foo" do |foo|
      foo.file "bin/foo" do |bin|
        bin << <<-end_bin.gsub(/^[ ]{10}/,'')
          #!/usr/bin/ruby
          puts "FILE: \#{__FILE__} builded."
        end_bin
      end
      assert foo["bin/foo"].exist?
      assert_equal <<-end_bin.gsub(/^[ ]{8}/,''), foo["bin/foo"].read
        #!/usr/bin/ruby
        puts "FILE: \#{__FILE__} builded."
      end_bin
    end
  end

  should "add and create empty files" do
    @project << "config/foo.yml" << "test/foo_test.rb"
    assert @project["config/foo.yml"].exist?
    assert_equal 0, @project["config/foo.yml"].size

    assert @project["test/foo_test.rb"].exist?
    assert_equal 0, @project["test/foo_test.rb"].size
  end

end

