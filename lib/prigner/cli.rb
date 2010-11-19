# == Command-Line Interface
#
# This module look a command placed in CLI directory and run it.
module Prigner::CLI

  require "rbconfig"

  # Ruby VM installed in OS.
  def self.ruby
    File.join(*::RbConfig::CONFIG.values_at("bindir", "ruby_install_name")) +
    ::RbConfig::CONFIG["EXEEXT"]
  end

  # The CLI path.
  def self.path
    "#{Prigner::ROOT}/lib/prigner/cli"
  end

  # List all templates as commands.
  def self.templates
    Prigner::Template.all.map do |namespace, templates|
      templates.map{ |template| template.mask }
    end.flatten
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
  def self.run(*args)
    command = args.shift if commands.include? args.first
    raise RuntimeError, "unknown command '#{args.first}'" unless command
    rubyopt = "-I#{Prigner::ROOT}/lib"
    exec ruby, rubyopt, source(command), *args
  end

  class Status

    attr_reader :formats

    attr_reader :count

    attr_reader :states

    attr_reader :current

    def initialize
      @states = {
        :success => :done,
        :failure => :fail,
        :error   => :err
      }
      @formats = {
        :title => "\n* %-74s",
        :info  => "\n  %-70s [%4s]"
      }
      @count = {}
      @states.keys.each{|k| @count[k] = 0 }
    end

    def setup(&block)
      instance_eval(&block)
    end

    def state(key, value)
      return unless @states.has_key?key
      @states[key] = value
      @count[key] = 0
    end

    def format(key, format)
      @formats[key] = "#{format}\n" if @formats.has_key?key
    end

    def increment!
      @count[@current] += 1
    end

    def start(title, &block)
      printf @formats[:title], title
      hash = yield block
      hash.each do |message, status|
        @current = status ? :success : :failure
        printf @formats[:info], message, @states[@current]
        increment!
      end
    end

  end

end


