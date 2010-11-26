# Copyright (c) 2010 Codigorama
# Copyright (c) 2009 Hallison Batista

require "prigner"

program = :prign
command = File.basename(__FILE__, ".rb")

def templates_by_namespace(options = { :indent => nil, :details => false })
  puts "#{Prigner::Version}"
  puts "\nThe templates tagged with '*' are customized by user."
  message = []
  Prigner::Template.all.map do |namespace, list|
    message << "#{namespace}:"
    list.map do |template, custom|
      formatting = "#{options[:indent]}#{custom ? :* : :-} %s (%s)"
      attributes = [template.name, template.spec.version]
      if options[:details]
        formatting = "#{options[:indent]}#{custom ? :* : :-} %s (%s)\n" +
                     "#{options[:indent]}  %s\n" +
                     "#{options[:indent]}  Written by %s <%s>\n"
        attributes = [
          template.name,
          template.spec.version,
          template.spec.description,
          template.spec.author,
          template.spec.email
        ]
      end
      message << (formatting % attributes)
    end
  end
  puts "\n#{message.join("\n")}"
end

begin
  ARGV.options do |arguments|

    arguments.summary_indent = "  "
    arguments.summary_width  = 24
    arguments.banner = <<-end_banner.gsub /^[ ]{4}/, ''
      #{Prigner::Version}

      List all templates.

      Usage:
        #{program} #{command} <namespace>[:template] [options]
        #{program} #{command} [options]

    end_banner

    arguments.separator "Options:"

    options = {
      :indent  => arguments.summary_indent,
      :details => false
    }

    arguments.on("-h", "--help", nil, "Show this message.") do
      puts arguments
      exit 0
    end

    arguments.on("-d", "--details", nil, "Show template details.") do
      options[:details] = true
    end

    arguments.separator ""

    arguments.parse!

    unless ARGV.empty?
      name = ARGV.shift

      if template = Prigner::Template.load(*name.split(":"))
        arguments.banner = <<-end_banner.gsub /^[ ]{10}/, ''
        #{Prigner::Version}

        Template:
        #{template.mask} v#{template.spec.version}

        #{template.spec.description}

          Written by #{template.spec.author} <#{template.spec.email}>.

        Usage:
        #{program} #{command} #{template.mask} <path> [options]

        end_banner
      else
        raise RuntimeError, "unable to load template '#{name}'"
      end
    else
      templates_by_namespace(options)
      exit 0
    end

  end

rescue => error
  puts "\n#{program}: #{command}: #{error.message} (#{error.class})"
  exit 1
end

