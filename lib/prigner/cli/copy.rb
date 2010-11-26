# Copyright (c) 2010 Codigorama
# Copyright (c) 2009 Hallison Batista

require "prigner"

program = :prign
command = File.basename(__FILE__, ".rb")

begin
  ARGV.options do |arguments|

    noforce = true

    arguments.summary_indent = "  "
    arguments.summary_width  = 24
    arguments.banner = <<-end_banner.gsub /^[ ]{6}/, ''
      #{Prigner::Version}

      Usage:
        #{program} #{command} <namespace>[:template] [options]
        #{program} #{command} <namespace>[:template] <path> [options]

      Templates:
        #{Prigner::CLI.templates.sort.join("\n" + arguments.summary_indent)}

    end_banner

    arguments.separator "Options:"

    arguments.on("-h", "--help", nil, "Show this message.") do
      puts arguments
      exit 0
    end

    arguments.on("-f", "--force", TrueClass, "Force copy.") do
      noforce = false
    end

    arguments.separator ""

    unless ARGV.empty?
        arguments.parse!
      else
    #    raise RuntimeError, "unable to load template '#{name}'"
      puts arguments
      exit 0
    end

    template = Prigner::Template.load(*ARGV.shift.split(":"))
    path     = ARGV.empty? ? Prigner.shared_path.first : ARGV.shift
    status   = Prigner::CLI::Status.new

    include FileUtils

    puts Prigner::Version

    raise RuntimeError, <<-end.gsub(/^[ ]{6}|\n/,"") if File.exist?path and noforce
      unable to create path #{path}, the path exists
    end

    status.start "Copying template #{template.mask} to #{path}" do
      mkdir_p path
      Dir.glob("#{template.path}/**/**").sort.inject({}) do |hash, source|
        destfile = source.to_s.gsub("#{Prigner::ROOT}/share/templates", path)
        if File.file? source
          mkdir_p File.dirname(destfile)
          cp source, destfile, :noop => true
          hash[destfile.gsub(Prigner.user_home, "~")] = File.exist? destfile
        end
        hash
      end
    end

  end

rescue => error
  puts "\n#{program}: #{command}: #{error.message} (#{error.class})"
  puts "\nTry '#{program} #{command} -h' or '#{program} #{command} --help' for more information."
  exit 1
end


