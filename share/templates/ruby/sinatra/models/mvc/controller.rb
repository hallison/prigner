<%namespace = project.upper_camel_case_namespace%>
class <%=namespace%>::Controllers::About < Sinatra::Base

  register Sinatra::Mapping

  set :views, File.join(<%=namespace%>::ROOT, "app", "views")

  map :root,  File.basename(__FILE__, ".*").downcase

  get root_path do
    erb :index
  end

end

