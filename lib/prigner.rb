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
  require "pathname"
  require "optparse"
  require "yaml"

  # Internal requirements
  require "prigner/extensions"

  # Root directory for project.
  ROOT = Pathname.new(__FILE__).dirname.join('..').expand_path.freeze

  # Modules
  autoload :Project,  "prigner/project"
  autoload :Model,    "prigner/model"
  autoload :Template, "prigner/template"
  autoload :Builder,  "prigner/builder"
  autoload :CLI,      "prigner/cli"

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

    # Default values.
    DEFAULTS = {
      "options"     => {},
      "directories" => [],
      "files"       => {}
    }

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
      DEFAULTS.update(attributes || {}).each do |attribute, value|
        instance_variable_set "@#{attribute}", value if self.respond_to? attribute
      end
    end

    # Load a Specfile and initialize a new Spec that be used in Template.
    def self.load(specfile)
      new(YAML.load_file(specfile))
    end

  end # Spec

  # == Binder to common filters
  #
  # When a new Project is created, then several filters are available to use
  # in Skel files.
  class Binder

    # Project.
    attr_reader :project

    # Template options.
    attr_reader :options

    alias option options

    # The binder work binding to Project filters and Template options for use
    # in Skel files.
    def initialize(project, options)
      @project, @options = project, options
    end

    def date
      Date.today.clone
    end

    # Check if an options is enabled in Template.
    def enabled?(option, &block)
      yield block if @options[option].enabled
    end

    def binding #:nodoc:
      super
    end

  end

end # Prigner

