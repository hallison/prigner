# Copyright (c) 2010 Codigorama
# Copyright (c) 2009 Hallison Batista

require "prigner"

program = :prign
command = File.basename(__FILE__, ".rb")
@options = {}

def templates_by_namespace(indent)
  templates = Prigner::Template.all
  message = []
  templates.map do |namespace, list|
    message << "* #{namespace}"
    list.map do |template|
      message << ("#{indent}> %-16s %s" % [template.name, template.spec.description])
    end
  end
  message.join("\n")
end

def show(message)
  puts "#{Prigner::Version}"
  puts "\n#{message}"
end

begin

ARGV.options do |arguments|

  arguments.summary_indent = "  "
  arguments.summary_width  = 24
  arguments.banner = <<-end_banner.gsub /^[ ]{4}/, ''
    #{Prigner::Version}

    List all templates.

    Usage:
      #{program} #{command}

  end_banner

  if ARGV.empty?
    show(templates_by_namespace(arguments.summary_indent))
    exit 0
  else
    arguments.parse!
  end
end

rescue => error
  puts "\n#{program}: #{command}: #{error.message} (#{error.class})"
  exit 1
end

