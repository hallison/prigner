# Copyright (c) 2010 Hallison Batista

require "lib/prigner"

program = :prign
command = File.basename(__FILE__, ".rb")
namespace = ARGV.first unless ARGV.empty?
options = {}

def templates_by_namespace(indent)
  templates = Prigner::Template.all
  message = ""
  templates.map do |namespace, list|
    message += "* #{namespace}\n"
    list.keys.map do |template|
      message += "#{indent}> #{template}\n"
    end
  end
  message
end

def full_names
  Prigner::Template.all.sort.map do |namespace, list|
    list.keys.map do |template|
      "#{namespace}:#{template}"
    end
  end.join("\n")
end

def show(message)
  puts "#{Prigner::Version}"
  puts "\n#{message}"
  puts "\nSee 'new' command if you want create a new project."
end

ARGV.options do |arguments|

  arguments.summary_indent = "  "
  arguments.summary_width  = 24
  arguments.banner = <<-end_banner.gsub /^[ ]{4}/, ''
    #{Prigner::Version}

    List all templates.

    Usage:
      #{program} #{command} [option]

  end_banner

  arguments.separator "Options:"

  arguments.on("-n", "--names", nil, "List all templates by name.") do
    puts full_names
  end

  arguments.on("-h", "--help", nil, "Show this message.") do
    puts arguments
  end

  begin
    if ARGV.empty?
      show(templates_by_namespace(arguments.summary_indent))
      exit 0
    else
      arguments.parse!
    end
  rescue => error
    puts error.message
    exit 1
  end

end


