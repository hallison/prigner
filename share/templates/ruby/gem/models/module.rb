#@ --- 
#@ :tag: 0.0.1
#@ :date: <%=date%>
#@ :milestone: Pre-Alpha
#@ :timestamp: <%=Time.now.strftime "%F %T %z"%>

# encoding: UTF-8

module <%=project.upper_camel_case_namespace%>

  # RubyGems
  require "rubygems" unless $LOADED_FEATURES.include? "rubygems.rb"

  # Standard library requirements
  require "pathname"
  require "yaml"

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

end

