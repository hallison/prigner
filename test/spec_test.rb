require "test/unit"
require "test/helpers"
require "lib/prigner"

class SpecTest < Test::Unit::TestCase

  def setup
    @info = {
      "author" => "John Doe",
      "email" => "john.doe@se7en.com",
      "version" => "0.1.0",
      "description" => "Default template for Ruby projects"
    }
    @options = {
      "svn" => "Include Subversion keywords in code.",
      "git" => "Enable Git flags in templates.",
      "bin" => {
        "description" => "Include executable file in bin/<name>.",
        "files" => {
          "executable" => "bin/(project)",
          "cli.rb" => "lib/(project)/cli.rb"
        }
      },
      "test" => {
        "description" => "Include test files.",
        "files" => {
          "empty_test.rb" => "test/(project)_test.rb",
          "testhelper.rb" => "test/helper.rb"
        }
      }
    }
    @directories = [
      "test/fixtures",
      "lib/(project)"
    ]
    @files = {
      "README.mkd" => nil,
      "module.rb"  => "lib/(project).rb",
    }
    specfile = "#{FIXTURES}/templates/shared/templates/ruby/default/specfile"
    @spec = Prigner::Spec.load(specfile)
  end

  should "check basic information about template" do
    @info.each do |attribute, value|
      assert_equal value, @spec.send(attribute)
    end

    assert_equal @directories.sort, @spec.directories.sort

    %w{options files}.each do |checker|
      instance_variable_get("@#{checker}").each do |attribute, value|
        checking = @spec.send(checker)[attribute]
        assert_equal value, checking
      end
    end
  end

  should "set default values when initialize with emtpy attributes" do
    spec = Prigner::Spec.new(nil)
    assert_kind_of Array, spec.directories
    assert_kind_of Hash,  spec.files
    assert_kind_of Hash,  spec.options
  end

  should "raise runtime error if specfile is nil" do
    assert_raises RuntimeError do
      Prigner::Spec.load(nil)
    end
  end

  should "raise runtime error if specfile not exist" do
    assert_raises RuntimeError do
      Prigner::Spec.load("not/found")
    end
  end
end

