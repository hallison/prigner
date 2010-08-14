BASE_PATH = "#{File.expand_path(File.dirname(__FILE__))}/.."

$LOAD_PATH.unshift(BASE_PATH) unless $LOAD_PATH.include? BASE_PATH

require "test/unit"
require "test/helpers"
require "lib/rubify"

class TemplateTest < Test::Unit::TestCase

  PATH = Pathname.new(BASE_PATH)

  def setup
    @binds    = {
      :name    => "foo",
      :version => "0.1.0",
      :author  => "John Doe",
      :functions => [
        :create,
        :recover,
        :update,
        :delete
      ]
    }
    @template = Rubify::Template.new("test/fixtures/templates/foo.rb.erb", @binds)
  end

  should "check basic attributes of template" do
    assert_equal "test/fixtures/templates/foo.rb".to_path, @template.result_file
  end

  should "check bind values" do
    @binds.map do |key, value|
      assert_equal value, @template.bind.send(key)
    end
  end

  should "create file" do
    @template.convert!

    assert File.exist?(@template.result_file)

    assert_equal <<-end_result.gsub(/^[ ]{6}/, ''), @template.result_file.read
      #!/usr/bin/ruby
      # program: foo
      # version: 0.1.0
      # author : John Doe

      def create
        # type code for create
      end

      def recover
        # type code for recover
      end

      def update
        # type code for update
      end

      def delete
        # type code for delete
      end

    end_result
  end

end

