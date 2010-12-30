#@ --- 
#@ :tag: 0.1.0
#@ :date: <%=date%>
#@ :timestamp: <%=Time.now.strftime "%F %T %z"%>

# encoding: UTF-8
<%namespace = project.upper_camel_case_namespace%>
module <%=namespace%>

  ROOT = File.join(File.dirname(__FILE__), "..")

  # RubyGems
  require "rubygems" unless $LOADED_FEATURES.include? "rubygems.rb"

  # Standard library requirements
  require "pathname"
  require "yaml"

  # Internal requirements

  class << self

    def config
      Config
    end

    # Return the current version.
    def version
      @version ||= Version.current
    end

  end

  module Config
<%if option.mvc.enabled%>
    class Database < Struct.new(:adapter, :database, :user, :password, :host, :port)

      # Database URI.
      def uri
        hostname = port ? "#{host}:#{port}" : host
        "#{adapter}://#{user}:#{password}@#{hostname}/#{database}"
      end

      # Load configuration from <tt>config/database.yml</tt>.
      def self.load_config
        config = YAML.load_file(File.join(PATH, "database.yml"))
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
<%end%>
    class << self

      def path_to(*args)
        File.join(<%=namespace%>::ROOT, *args.map{|p|p.to_s})
      end
<%if option.mvc.enabled%>
      def path_to_application(*args)
        path_to("app", *args.map{|p|p.to_s})
      end

      # Load Database configuration. See Database#load_config.
      def database
        Database.load_config
      end
<%end%>
    end
  end
  # The objective of this class is to implement various ideas proposed by the
  # Semantic Versioning Specification (see reference[http://semver.org/]).
  class Version

    FILE = Pathname.new(__FILE__).freeze

    attr_accessor :date, :tag

    attr_reader :timestamp

    # Basic initialization of the attributes using a single hash.
    def initialize(attributes = {})
      attributes.each do |attribute, value|
        send("#{attribute}=", value) if respond_to? "#{attribute}="
      end
      @timestamp = attributes[:timestamp]
    end

    # The numbering of the major, minor and patch values.
    def numbering
      self.tag.split(".").map do |key|
        if key.match(/^(\d{1,})(\w+).*$/)
          [ $1.to_i, $2 ]
        else
          key.to_i
        end
      end.flatten
    end

    def to_hash
      [:tag, :date, :timestamp].inject({}) do |hash, key|
        hash[key] = send(key)
        hash
      end
    end

    def save!
      source = FILE.readlines
      source[0..3] = self.to_hash.to_yaml.to_s.gsub(/^/, '#@ ')
      FILE.open("w+") do |file|
        file << source.join("")
      end
      self
    end

    class << self
      def current
        yaml = FILE.readlines[0..3].
                 join("").
                 gsub(/\#@ /,'')
        new(YAML.load(yaml))
      end

      def to_s
        name.match(/(.*?)::.*/)
        "#{$1} v#{current.tag} (#{current.date})"
      end
    end # self

  end # Version

end

