<%namespace = project.upper_camel_case_namespace%>
module <%=namespace%>::Config

  class Database < Struct.new(:adapter, :database, :user, :password, :host, :port)

    # Database URI.
    def uri
      hostname = port ? "#{host}:#{port}" : host
      "#{adapter}://#{user}:#{password}@#{hostname}/#{database}"
    end

    # Load configuration from <tt>config/database.yml</tt>.
    def self.load_config
      config = YAML.load_file(File.join(<%=namespace%>::ROOT, "config", "database.yml"))
      new(
        config["adapter"],
        config["database"],
        config["user"],
        config["password"],
        config["host"],
        config["port"]
      )
    end

  end

  # Load Database configuration. See Database#load_config.
  def self.database
    Database.load_config
  end

end

