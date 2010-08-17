BASE_PATH = "#{File.expand_path(File.dirname(__FILE__))}/.."

$LOAD_PATH.unshift(BASE_PATH) unless $LOAD_PATH.include? BASE_PATH

require "test/unit"
require "test/helpers"
require "lib/rubify"

class TemplateTest < Test::Unit::TestCase

  def setup
    @config = {
      :options => {
        :gem   => "Include RubyGems contents.",
        :setup => "Include setup.rb file for install."
      }
    }
    @path     = "#{BASE_PATH}/test/fixtures/templates/project"
    @template = Rubify::Template.new(@path)
  end

  should "check basic attributes of template" do
    assert_equal "project", @template.name
    assert_equal @path, @template.path
  end

  should "check options loaded from config file" do
    @config.each do |key, values|
      values.each do |name, desc|
        assert_equal desc, @template.options.send(name).description
      end
    end
  end

  should "check if options disable by default" do
    @config.each do |key, values|
      values.each do |name, desc|
        assert !@template.options.send(name).enabled
      end
    end
  end
end

