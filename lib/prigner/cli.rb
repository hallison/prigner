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

  module Utils
    def status(title, &block)
      printf "* %-74s ...\n", title
      message, status = yield block
      status = status ? :done : :fail
    rescue Exception => error
      message, status = "#{error.class}: #{error.message}", :err
    ensure
      printf "  %-70s [%4s]\n", message, status
    end
  end

end


