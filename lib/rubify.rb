#@ --- 
#@ :tag: 0.1.0
#@ :date: 2009-07-16
#@ :milestone: Pre-Alpha
#@ :timestamp: 2009-07-16 14:05:16 -04:00

# Copyright (c) 2009, 2010, Hallison Batista

$LOAD_PATH.unshift(File.dirname(__FILE__))

# The Rubify is a template builder which help developers in DRY.
module Rubify

  # Core requires
  require 'pathname'
  require 'optparse'
  require 'yaml'

  # Internal requires
  require 'rubify/extensions'

  # Root directory for project.
  ROOT = Pathname.new(__FILE__).dirname.join('..').expand_path.freeze

  # Modules
  autoload :Project,  "rubify/project"
  autoload :Template, "rubify/template"

  # Version
  def self.version
    @version ||= Version.current
  end

  # Base object. The purpose of this object is initialize other using
  # hash attributes.
  class BaseObject #:nodoc:

    def initialize(attributes = {})
      attributes.each do |attribute, value|
        send("#{attribute}=", value) if respond_to? "#{attribute}="
      end
    end

  end

  class Version < BaseObject #:nodoc:

    FILE = Pathname.new(__FILE__).freeze

    attr_accessor :tag, :date, :milestone
    attr_reader :timestamp

    def initialize(attributes = {})
      super(attributes)
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
    end # class self

  end

end # module Rubify

