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
    @file  = "#{BASE_PATH}/test/fixtures/models/newproject.rb"
    @model = Rubify::Model.new("test/fixtures/templates/project/lib/project.rb.erb", @binds)
  end

  def teardown
    File.delete(@file) if File.exist?(@file)
  end

  should "check bind values" do
    @binds.map do |key, value|
      assert_equal value, @model.bind.send(key)
    end
  end

  should "build contents" do
    @model.build!

    assert_equal <<-end_result.gsub(/^[ ]{6}/, ''), @model.content
      #!/usr/bin/ruby
      # name   : project
      # version: 0.1.0
      # author : John Doe

      module Project

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

      end
    end_result
  end

  should "draw file using content parsed" do
    @model.draw @file
    assert File.exist?(@file)
  end

  should "creates the path of file before draw" do
    file = "#{BASE_PATH}/test/fixtures/models/should-exist-new-project.rb"
    @model.draw file
    assert File.exist?(file)
    File.delete(file) 
  end

end

