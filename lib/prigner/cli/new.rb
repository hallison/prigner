# Copyright (c) 2010 Hallison Batista

require "prigner"

program = :prign
command = File.basename(__FILE__, ".rb")

begin
  ARGV.options do |arguments|

    arguments.summary_indent = "  "
    arguments.summary_width  = 24
    arguments.banner = <<-end_banner.gsub /^[ ]{6}/, ''
      #{Prigner::Version}

      Usage:
        #{program} #{command} <namespace>[:template] <path> [options]

      Templates:
        #{Prigner::CLI.templates.sort.join("\n" + arguments.summary_indent)}

    end_banner

    unless ARGV.empty?
      arguments.parse!

      name = ARGV.shift

      template = Prigner::Template.load(*name.split(":"))

      if template
        arguments.banner = <<-end_banner.gsub /^[ ]{10}/, ''
          #{Prigner::Version}

          Usage:
            #{program} #{command} #{template.mask} <path> [options]

        end_banner

        if template.options
          arguments.separator "Options:"

          template.options.members.map do |name|
            option = template.options[name]
            arguments.on("-#{name[0..0]}", "--#{name}", nil, option.description) do
              option.enabled = true
            end
          end
        end

      else
        raise RuntimeError, "unable to load template '#{name}'"
      end
    end

    path = unless ARGV.empty?
             arguments.parse!
             path = ARGV.shift unless name.nil?
           else
             puts arguments
             exit 0
           end

    project = Prigner::Project.new(path)
    builder = Prigner::Builder.new(project, template)

    status = Prigner::CLI::Status.new

    status.setup do
      state :success, :created
      state :failure, :fail
      state :error,   :error
      format :title, "\n* %-74s"
      format :info,  "  %-69s [%7s]"
    end

    puts Prigner::Version

    status.start "Creating project path" do
      builder.make_project_path
    end

    status.start "Creating directories" do
      builder.make_project_directories
    end

    status.start "Writing files" do
      builder.make_project_files
    end

  end

rescue => error
  puts "#{program}: #{command}: #{error.message} (#{error.class})"
  puts "Try '#{program} #{command} -h' or '#{program} #{command} --help' for more information."
  exit 1
end

