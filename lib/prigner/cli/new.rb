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

    end_banner

    # if template and path
    #   template.draw path
    #   puts "* Directories"
    #   template.directories.map do |directory|
    #     printf "  > %s\n", directory.gsub("#{Dir.pwd}/", "")
    #   end
    #   puts "* Files"
    #   template.models.map do |model, file|
    #     printf "  > %s\n", file.gsub("#{Dir.pwd}/", "")
    #   end
    #   printf ":: Project '%s' was created successfully using %s:%s template.\n", path, template.namespace, template.name
      unless ARGV.empty?
        name  = ARGV.shift
        path  = ARGV.shift unless name.nil?

        template = Prigner::Template.load(*name.split(":"))

        if template
          arguments.banner = <<-end_banner.gsub /^[ ]{12}/, ''
            #{Prigner::Version}

            Usage:
              #{program} #{command} #{template.mask} <path> [options]

          end_banner

          arguments.separator "Options:"

          template.options.members.map do |name|
            option = template.options[name]
            arguments.on("-#{name[0..0]}", "--#{name}", nil, option.description) do
              option.enabled = true
            end
          end
        else
          raise RuntimeError, "unable to load template '#{name}'"
        end
      end

      unless path
        puts arguments
        exit 0
      end

      arguments.parse!

      project = Prigner::Project.new(path)
      builder = Prigner::Builder.new(project, template)

      puts "* Creating project #{project.name} (#{project.path.gsub(Dir.pwd, ".")})"

      builder.make_project_path do |dirname, status|
        puts "* Creating path #{dirname} ... #{status ? :ok : :fail}"
      end

      builder.make_project_directories do |dirname, status|
        puts "* Creating directory #{dirname} ... #{status ? :ok : :fail}"
      end

      builder.make_project_files do |filename, status|
        puts "* Writing file #{filename} ... #{status ? :ok : :fail}"
      end

  end

rescue => error
  puts "#{program}: #{command}: #{error.message} (#{error.class})"
  puts "Try '#{program} #{command} -h' or '#{program} #{command} --help' for more information."
  exit 1
end

