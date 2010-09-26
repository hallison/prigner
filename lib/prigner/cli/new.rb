# Copyright (c) 2010 Hallison Batista

require "lib/prigner"

program = :prign
command = File.basename(__FILE__, ".rb")

ARGV.options do |arguments|

  arguments.summary_indent = "  "
  arguments.summary_width  = 24
  arguments.banner = <<-end_banner.gsub /^[ ]{4}/, ''
    #{Prigner::Version}

    Usage:
      #{program} #{command} <namespace>[:template]

  end_banner

  arguments.separator "Options:"

  arguments.on("-h", "--help",    nil, "Show this message.")        { puts arguments }
  begin
    if ARGV.empty?
      puts arguments
      exit 0
    else
      arguments.parse!
    end
  rescue => error
    puts error.message
    exit 1
  end

end


