<%namespace = project.upper_camel_case_namespace%>
class <%=namespace%>::Controllers::About < Sinatra::Base

  register Sinatra::Mapping

  set :config, <%=namespace%>::Config
  set :views, config.path_to_application(:views)

  map :root,  File.basename(__FILE__, ".*").downcase

  get root_path do
    erb :index
  end

end

