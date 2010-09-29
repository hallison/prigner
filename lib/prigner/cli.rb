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


