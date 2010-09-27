#@ --- 
#@ :tag: 0.1.0
#@ :date: 2009-07-16
#@ :milestone: Pre-Alpha
#@ :timestamp: 2009-07-16 14:05:16 -04:00
# encoding: UTF-8

# Copyright (c) 2009, 2010, Hallison Batista

$LOAD_PATH.unshift(File.dirname(__FILE__))

# The Prigner is a Projec Design Kit which help developers in DRY.
module Prigner

  # Standard library requirements
  require 'pathname'
  require 'optparse'
  require 'yaml'

  # Internal requirements
  require 'prigner/extensions'

  # Root directory for project.
  ROOT = Pathname.new(__FILE__).dirname.join('..').expand_path.freeze

  # Modules
  autoload :Model,    "prigner/model"
  autoload :Template, "prigner/template"
  autoload :Builder,  "prigner/builder"

  # Return the current version.
  def self.version
    @version ||= Version.current
  end

  class Version #:nodoc:

    FILE = Pathname.new(__FILE__).freeze

    attr_accessor :tag, :date, :milestone
    attr_reader :timestamp

    def initialize(attributes = {})
      attributes.each do |attribute, value|
        send("#{attribute}=", value) if respond_to? "#{attribute}="
      end
      @timestamp = attributes[:timestamp]
    end

    def to_hash
      [:tag, :date, :milestone, :timestamp].inject({}) do |hash, key|
        hash[key] = send(key)
        hash
      end
    end

    def save!
      @date = Date.today
      source = FILE.readlines
      source[0..4] = self.to_hash.to_yaml.to_s.gsub(/^/, '#@ ')
      FILE.open("w+") do |file|
        file << source.join("")
      end
      self
    end

    class << self
      def current
        yaml = FILE.readlines[0..4].
                 join("").
                 gsub(/\#@ /,'')
        new(YAML.load(yaml))
      end

      def to_s
        name.match(/(.*?)::.*/)
        "#{$1} v#{current.tag}, #{current.date} (#{current.milestone})"
      end
    end # self

  end # Version

  # == Specification class
  #
  # This class implements the basic attributes for Template specification.
  class Spec

    # Author name of template.
    attr_reader :author

    # Email for more information about template.
    attr_reader :email

    # Template version.
    attr_reader :version

    # Template description.
    attr_reader :description

    # Options that enables several features in model files.
    attr_reader :options

    # List of directories that will be created in project tree.
    attr_reader :directories

    # List of files that link a model to result file.
    attr_reader :files

    # Initialize the spec using options in Hash.
    #
    # Example:
    #
    #   Prigner::Spec.new :author  => "Anakin Skywalker",
    #                     :email   => "anakin@tatooine.net",
    #                     :version => "1.0.0",
    #                     :options => {
    #                       "lightsaber" => "Enable red light saber",
    #                       "force"      => "Use the force"
    #                     },
    #                     :directories => %w{galactic/republic galactic/empire},
    #                     :files       => {
    #                       "son.erb"    => "jedi/luke_skywalker.knight"
    #                       "chosen.erb" => "rebels/leia_organa.princess"
    #                     }
    def initialize(attributes = {})
      attributes.each do |attribute, value|
        instance_variable_set "@#{attribute}", value if self.respond_to? attribute
      end
    end

    # Load a Specfile and initialize a new Spec that be used in Template.
    def self.load(specfile)
      new(YAML.load_file(specfile))
    end

  end # Spec

  # == Project
  #
  # This class is a simple implementation of a directory tree using the Pathname
  # class from Ruby Standard Library. It is used in model files.
  class Project

    # Project name.
    attr_reader :name

    alias project name

    # Project files.
    attr_reader :path

    # Project timestamp
    attr_reader :timestamp

    # Initialize a new project directory path.
    def initialize(path)
      @path = File.expand_path(path =~ /^\/.*/ ? path : "#{Dir.pwd}/#{path}")
      @name = File.basename(@path)
      @timestamp = DateTime.now
    end

    def name_splited
      @name.split(/[-_]/)
    end

    def namespace(joiner = "::")
      name_splited.join(joiner)
    end

    def upper_camel_case_namespace(joiner = "::")
      name_splited.map{ |str| str.capitalize }.join(joiner)
    end

    def lower_camel_case_namespace(joiner = "::")
      return name if name_splited.size == 0
      name_splited[1..-1].map do |str|
        str.capitalize
      end.unshift(name_splited.first).join(joiner)
    end

    def upper_case_namespace(joiner = "::")
      upper_camel_case_namespace(joiner).upcase
    end

    def lower_case_namespace(joiner = "::")
      upper_camel_case_namespace(joiner).downcase
    end

    def upper_camel_case_name
      upper_camel_case_namespace(nil)
    end

    alias class_name upper_camel_case_name

    def lower_camel_case_name
      lower_camel_case_namespace(nil)
    end

    def user
      Etc.getpwnam(Etc.getlogin)
    end

    def author
      self.user.gecos.split(",").first
    end

  end # Project

  class Bind
    attr_reader :project

    attr_reader :options

    alias option options

    def initialize(project, options)
      @project, @options = project, options
    end

    def date
      Date.today
    end

    def enabled?(option, &block)
      yield block if @options[option].enabled
    end

    def binding
      super
    end

  end

  def self.build(path, namespace, basename = :default, &block)
    project  = Project.new(path)
    template = Template.load(namespace, basename)
    template
  end

  # == Prigner Command-Line Interface
  #
  # This module look a command placed in CLI directory and run it.
  module CLI
    require "rbconfig"

    # Ruby VM installed in OS.
    def self.ruby
      File.join(*::RbConfig::CONFIG.values_at("bindir", "ruby_install_name")) +
      ::RbConfig::CONFIG["EXEEXT"]
    end

    # The CLI path.
    def self.path
      "#{ROOT}/lib/prigner/cli"
    end

    # List of commands placed in <tt>lib/prigner/cli/</tt>.
    def self.commands
      Dir["#{path}/*.rb"].map do |source|
        File.basename(source, ".rb")
      end.sort
    end

    # Source command placed in CLI directory.
    def self.source(command)
      "#{path}/#{command}.rb"
    end

    # Look command in *CLI* directory and execute (by exec).
    def self.run(command)
      exec ruby, source(command), *ARGV if commands.include? command
    end

  end

end # Prigner

