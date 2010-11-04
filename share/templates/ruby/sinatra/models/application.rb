<%namespace = project.upper_camel_case_namespace%>
require "sinatra"
require "sinatra/mapping"
<%if option.mvc.enabled%>
# This module load all source controllers placed in <tt>app/controllers</tt>.
module <%=namespace%>::Controllers
  Dir["#{<%=namespace%>::ROOT}/app/controllers/*.rb"].each { |controller| require controller }
end
<%end%>
class <%=namespace%>::Application < Sinatra::Base

  register Sinatra::Mapping
<%if option.mvc.enabled%>
  <%=namespace%>::Controllers::constants.each do |controller|
    use <%=namespace%>::Controllers::const_get(controller)
  end

  set :views, File.join(<%=namespace%>::ROOT, "app", "views")
<%end%>
  map :root

  get root_path do
    <%= option.mvc.enabled ? "erb :index" : "\"\#{#{namespace}::Version} works!\"" %>
  end

end

