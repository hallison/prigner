<%namespace = project.upper_camel_case_namespace%>
require "sinatra/base"
require "sinatra/mapping"

# This module load all source controllers placed in <tt>app/controllers</tt>.
module <%=namespace%>::Controllers
  Dir.glob(<%=namespace%>.config.path_to_application("controllers", "*.rb")).each do |controller|
    require controller
  end

  def self.all
    constants.map do |constant|
      const_get constant
    end
  end

end

class <%=namespace%>::Application < Sinatra::Base

  register Sinatra::Mapping
<%if option.mvc.enabled%>
  set :config, <%=namespace%>::Config
  set :controllers, <%=namespace%>::Controllers.all
  set :views, config.path_to_application(:views)

  controllers.each do |controller|
    use controller
  end
<%end%>
  map :root

  get root_path do
    <%= option.mvc.enabled ? "erb :index" : "\"\#{#{namespace}::Version} works!\"" %>
  end

end

