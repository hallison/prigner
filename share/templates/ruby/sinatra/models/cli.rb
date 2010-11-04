# == Command-Line Interface
#
# This module look a command placed in CLI directory and run it.
module <%=project.upper_camel_case_namespace%>

module CLI

  require "rbconfig"

  # Ruby VM installed in OS.
  def self.ruby
    File.join(*::RbConfig::CONFIG.values_at("bindir", "ruby_install_name")) +
    ::RbConfig::CONFIG["EXEEXT"]
  end

  # The CLI path.
  def self.path
    "#{<%=project.upper_camel_case_namespace%>::ROOT}/lib/<%=project.name%>/cli"
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
    exec ruby, rubyopt, source(command), *args
  end

end

end

