require "lib/<%=project.name%>"
require "<%=option.mvc.enabled ? "app/#{project.name}" : "lib/#{project.name}/application"%>"

run <%=project.upper_camel_case_namespace%>::Application
