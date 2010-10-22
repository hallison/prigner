require "rake/clean"
require "lib/prigner"

# Configurations
# =============================================================================

def rdoc(*args)
  @rdoc ||= if Gem.available? "hanna"
              ["hanna", "--fmt", "html", "--accessor", "option_accessor=RW", *args]
            else
              ["rdoc", *args]
            end
  sh @rdoc.join(" ")
end

def test(pattern)
  testfiles = Dir[pattern]
  if Gem.available? "turn"
    sh [ "turn", *testfiles ].join(" ")
  else
    testfiles.each do |testfile|
      sh "ruby #{testfile}"
    end
  end
end

def git(cmd, *args)
  `git #{cmd.to_s.gsub('_','-')} #{args.join(' ')}`
end

def manifest
  @manifest ||= git(:ls_files).split("\n").sort.reject do |out|
    out =~ /^\./ || out =~ /^doc/
  end.map do |file|
    "    #{file.inspect}"
  end.join(",\n")
end

def version
  @version ||= Prigner.version
end

def tag
  git(:tag).split("\n").last
end

def release_notes
  @release_notes ||= Pathname.new("v#{spec.version}.rdoc")
end

def log
  yaml = git :log,
             "--date=short",
             "--format='- head: %d%n  date: %cd%n  summary: %s%n  notes: \"%n%b\"%n'"
  YAML.load(yaml)
end

def specfile
  @specfile ||= Pathname.new("prigner.gemspec")
end

def spec
  @spec ||= eval(specfile.read)
end

def package_path
  specfile.dirname.join("pkg").join("#{File.basename(spec.file_name, '.*')}")
end

def package(ext = "")
  specfile.dirname.join("#{package_path}#{ext}")
end

# Documentation
# =============================================================================

CLOBBER << FileList["doc/*"]

file "doc/api/index.html" => FileList["lib/**/*.rb", "README.rdoc", "CHANGELOG"] do |filespec|
  rm_rf "doc"
  rdoc "--op", "doc/api",
       "--charset", "utf8",
       "--main", "'Prigner'",
       "--title", "'Prigner v#{version.tag} API Documentation'",
       "--inline-source",
       "--promiscuous",
       "--line-numbers",
       filespec.prerequisites.join(" ")
end

desc "Build API documentation (doc/api)."
task :doc => "doc/api/index.html"

desc "Build CHANGELOG file."
task :changelog do
  open("CHANGELOG", "w+") do |changelog|
    title = lambda do |charlevel, text|
      text << "\n" << charlevel
    end

    changelog << "= #{Prigner::Version} - Changelog"

    historic = log.group_by { |entry| entry["date"] }

    historic.keys.sort.reverse.map do |date|
      changelog << "\n\n" << "== #{date}" << "\n"

      for entry in historic[date]
        notes = entry["notes"]
        changelog << "\n* #{entry["summary"]}."
        unless notes.empty?
          changelog << notes.strip.gsub(/([\*-].*?)/){ "\n  #{$1}" }
        end
      end
    end

    puts "Successfully updated the CHANGELOG file with #{historic.keys.size} dates."
  end
end

file "CHANGELOG" => :changelog

# Versioning
# =============================================================================

desc "Dump version (current v#{version.tag})."
task :version, [:counter,:release] do |spec, args|
  numbering = version.numbering
  tagnames  = %w[major minor patch]

  if index = tagnames.index(args[:counter])
    numbering[index] += 1
    numbering.fill(0, (index + 1)..-1)
  else
    numbering[-1] += 1
  end

  numbering[-1] = "#{numbering[-1]}#{args[:release]}"
  version.tag   = numbering.join(".")
  version.save!
  puts version.to_hash.to_yaml
end

namespace :version do
  desc "Update version date (current #{version.date})."
  task :date, [:date] do |spec, args|
    require "parsedate"
    require "date"
    yyyy, mm, dd = ParseDate.parsedate(args[:date]).compact if args[:date]
    version.date = (yyyy && mm && dd) ? Date.new(yyyy, mm, dd) : Date.today
    version.save!
    puts version.to_hash.to_yaml
  end
end

# Packaging
# =============================================================================

CLOBBER << FileList["#{package_path.dirname}/*"]

task :tagged do
  abort "The gemspec not updated to version #{version.tag} (#{spec.version})" \
    unless spec.version.to_s == version.tag
  abort "The version #{version.tag} is not tagged." \
    unless tag[1..-1] == version.tag
end

file specfile => FileList["{bin,lib,test}/**", "Rakefile"] do
  spec = specfile.read

  puts "Updating version ..."
    spec.sub! /spec\.version\s*=\s*".*?"/,  "spec.version = #{version.tag.inspect}"

  puts "Updating date of version ..."
    spec.sub! /spec\.date\s*=\s*".*?"/,     "spec.date = #{version.date.to_s.inspect}"

  puts "Updating file list ..."
    spec.sub! /spec\.files\s*=\s*\[.*?\]/m, "spec.files = [\n#{manifest}\n  ]"

  specfile.open("w+") { |file| file << spec }

  puts "Successfully update #{specfile} file"
end

directory package_path.to_s

file package(".gem") => [ specfile, package_path.dirname ] do |file|
  sh "gem build #{specfile}"
  mv spec.file_name, file.prerequisites.last
end

file package(".tar.gz") => [ specfile, package_path ] do |file|
  spec.files.each do |source|
    package_path.join(source).dirname.mkpath
    cp source, package_path.join(source)
  end
  cd package_path.dirname do
    sh "tar czvf #{package(".tar.gz").basename} #{package_path.basename}/*"
  end
end

desc "Build packages."
task :package => [package(".gem"), package(".tar.gz")]

desc "Release gem package to repositories."
task :release => [ :tagged, :package ] do
  sh "gem push #{package('.gem')}"
  [%w[release .gem], %w[file .tar.gz]].each do |file, ext|
    sh <<-endsh.gsub(/^[ ]{6}/,"")
      rubyforge add_#{file} #{spec.rubyforge_project} #{spec.name} #{spec.version} #{package(ext)}
    endsh
  end
  if release_notes.exist?
    sh <<-endsh.gsub(/^[ ]{6}/,"")
      rubyforge post_news #{spec.rubyforge_project} 'Prigner v#{spec.version} released' '#{release_notes.read}'
    endsh
  end
end

desc "Install gem package #{spec.file_name}."
task :install => :package do
  sh "gem install #{package('.gem')} --local"
end

desc "Uninstall gem package #{spec.file_name}."
task :uninstall do
  sh "gem uninstall #{spec.name} --version #{spec.version}"
end

task :gem => package(".gem")

# Test
# =============================================================================

desc "Run tests."
task :test, [:pattern] do |spec, args|
  test(args[:pattern] ? "test/#{args[:pattern]}_test.rb" : "test/*_test.rb")
end

# Default
# =============================================================================

task :default => :test

