<%= '# $Id$' if option.svn.enabled %>
BASE_PATH = "#{File.expand_path(File.dirname(__FILE__))}/.."

$LOAD_PATH.unshift(BASE_PATH) unless $LOAD_PATH.include? BASE_PATH

require "test/unit"
require "test/helpers"
require "lib/<%=project.name%>"

class <%=project.class_name%>Test < Test::Unit::TestCase

  def setup
    # start here
  end

  should "check the truth" do
    assert true
  end

end

