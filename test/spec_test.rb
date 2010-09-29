ROOT_PATH = "#{File.expand_path(File.dirname(__FILE__))}/.." unless defined? ROOT_PATH

$LOAD_PATH.unshift(ROOT_PATH) unless $LOAD_PATH.include? ROOT_PATH

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
      "git" => "Enable Git flags in templates."
    }
    @directories = [
      "test/fixtures",
      "lib/(project)"
    ]
    @files = {
      "README.mkd" => nil,
      "module.rb"  => "lib/(project).rb",
      "empty_test.rb" => "test/(project)_test.rb"
    }
    specfile = "#{ROOT_PATH}/test/fixtures/templates/shared/ruby/default/specfile"
    @spec = Prigner::Spec.load(specfile)
  end

  should "check basic informatio about template" do
    @info.each do |attribute, value|
      assert_equal value, @spec.send(attribute)
    end

    assert_equal @directories.sort, @spec.directories.sort

    %w{options files}.each do |checker|
      instance_variable_get("@#{checker}").each do |attribute, value|
        assert_equal value, @spec.send(checker)[attribute]
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

