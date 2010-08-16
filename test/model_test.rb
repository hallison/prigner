BASE_PATH = "#{File.expand_path(File.dirname(__FILE__))}/.."

$LOAD_PATH.unshift(BASE_PATH) unless $LOAD_PATH.include? BASE_PATH

require "test/unit"
require "test/helpers"
require "lib/rubify"

class ModelTest < Test::Unit::TestCase

  def setup
    @binds    = {
      :name    => "project",
      :version => "0.1.0",
      :author  => "John Doe",
      :functions => [
        :create,
        :recover,
        :update,
        :delete
      ]
    }
    @model = Rubify::Model.new("test/fixtures/templates/project/lib/project.rb.erb", @binds)
  end

  should "check basic attributes of model" do
    assert_equal "test/fixtures/templates/project/lib/project.rb".to_path, @model.result_file
  end

  should "check bind values" do
    @binds.map do |key, value|
      assert_equal value, @model.bind.send(key)
    end
  end

  should "create file" do
    @model.convert!

    assert File.exist?(@model.result_file)

    assert_equal <<-end_result.gsub(/^[ ]{6}/, ''), @model.result_file.read
      #!/usr/bin/ruby
      # name   : project
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

