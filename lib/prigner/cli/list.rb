# Copyright (c) 2010 Hallison Batista

require "lib/prigner"

program = :prign
command = File.basename(__FILE__, ".rb")
namespace = ARGV.first unless ARGV.empty?

ARGV.options do |arguments|

  arguments.summary_indent = "  "
  arguments.summary_width  = 24
  arguments.banner = <<-end_banner.gsub /^[ ]{4}/, ''
    #{Prigner::Version}

    List all templates.

    Usage:
      #{program} #{command}

  end_banner

  arguments.separator "Options:"

  arguments.on("-h", "--help",    nil, "Show this message.")        { puts arguments }

  begin
    if ARGV.empty?
      puts Prigner::Version
      puts
      templates = Prigner::Template.all
      templates.map do |namespace, list|
        puts "* #{namespace}"
        list.keys.map do |template|
          puts "#{arguments.summary_indent}> #{template}"
        end
      puts
      end
      puts "See 'new' command if you want create a new project."
      exit 0
    else
      arguments.parse!
    end
  rescue => error
    puts error.message
    exit 1
  end

end


