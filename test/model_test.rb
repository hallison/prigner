require "test/unit"
require "test/helpers"
require "lib/prigner"

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
    @file  = "#{FIXTURES}/model-result.rb"
    @model = Prigner::Model.new("#{FIXTURES}/model.rb.erb", @binds)
  end

  def teardown
    File.delete(@file) if File.exist?(@file)
  end

  should "check bind values" do
    @binds.map do |key, value|
      assert_equal value, @model.binder.send(key)
    end
  end

  should "build contents" do
    @model.build!

    assert_equal <<-end_result.gsub(/^[ ]{6}/, ''), @model.contents
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

  should "write file using contents parsed" do
    @model.write @file
    assert File.exist?(@file)
    assert_equal @model.contents, File.read(@file)
  end

  should "write result file" do
    file = "#{FIXTURES}/models/should-exist-new-project.rb"
    @model.write file

    assert_equal file, @model.file_written
    assert_equal @model.contents, File.read(file)
    assert File.exist?(file)

    File.delete(file) 
  end

end

