ROOT_PATH = "#{File.expand_path(File.dirname(__FILE__))}/.."

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
      "README.mkd.erb" => nil,
      "module.rb.erb"  => "lib/(project).rb",
      "empty_test.rb.erb" => "test/(project)_test.rb"
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

end

