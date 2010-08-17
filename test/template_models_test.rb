BASE_PATH = "#{File.expand_path(File.dirname(__FILE__))}/.."

$LOAD_PATH.unshift(BASE_PATH) unless $LOAD_PATH.include? BASE_PATH

require "test/unit"
require "test/helpers"
require "lib/rubify"

class TemplateModelsTest < Test::Unit::TestCase

  def setup
    @template = Rubify::Template.new("#{BASE_PATH}/test/fixtures/templates/project")
  end

  should "check total of models" do
    assert_equal 3, @template.models.size
  end

  should "check total of directories in tree" do
    assert_equal 3, @template.directories.size
  end

end

