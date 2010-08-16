BASE_PATH = "#{File.expand_path(File.dirname(__FILE__))}/.."

$LOAD_PATH.unshift(BASE_PATH) unless $LOAD_PATH.include? BASE_PATH

require "test/unit"
require "test/helpers"
require "lib/rubify"

class TemplateTest < Test::Unit::TestCase

  def setup
    @config   = {
      :options => {
        :gem => "Include RubyGems contents"
      }
    }
    @template = Rubify::Template.new("test/fixtures/templates/project")
  end

  should "check basic attributes of template" do
    assert_equal "Include RubyGems contents.",         @template.options.gem.description
    assert_equal "Include setup.rb file for install.", @template.options.setup.description
    assert !@template.options.gem.enabled
    assert !@template.options.setup.enabled
  end

end

