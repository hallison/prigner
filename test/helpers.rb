# This code extracted from book "Ruby Best Practices" and the code be found
# in http://github.com/sandal/rbp/blob/master/testing/test_unit_extensions.rb

TEST_HOME = File.expand_path(File.dirname(__FILE__)) unless defined? TEST_HOME
FIXTURES  = File.join(TEST_HOME, "fixtures") unless defined? FIXTURES

ENV['HOME'] = "#{FIXTURES}/templates/user"

module Test::Unit
  class TestCase
    def self.should(description, &block)
      test_name = "test_#{description.gsub(/\s+/,'_')}".downcase.to_sym
      defined = instance_method(test_name) rescue false
      raise "#{test_name} is already defined in #{self}" if defined
      if block_given?
        define_method(test_name, &block)
      else
        define_method(test_name) do
          flunk "No implementation provided for #{description}"
        end
      end
    end
  end
end

