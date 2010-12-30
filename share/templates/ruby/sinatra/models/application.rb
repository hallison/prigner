<%namespace = project.upper_camel_case_namespace%>
require "sinatra/base"
require "sinatra/mapping"

class <%=namespace%>::Application < Sinatra::Base

  register Sinatra::Mapping

  set :config, <%=namespace%>::Config
  set :views, config.path_to("views")

  map :root

  get root_path do
    <%= option.mvc.enabled ? "erb :index" : "\"\#{#{namespace}::Version} works!\"" %>
  end

end

