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

def log
  @log ||= `git log --date=short --format='%d;%cd;%s;%b;'`
end

def specfile
  @specfile ||= Pathname.new("prigner.gemspec")
end

def spec
  @spec ||= eval(specfile.read)
end

def package_path
  specfile.dirname.join("pkg").join("#{spec.name}-#{spec.version}")
end

def package(ext = "")
  specfile.dirname.join("#{package_path}#{ext}")
end

# Documentation
# =============================================================================

namespace :doc do

  CLOBBER << FileList["doc/*"]

  file "doc/api/index.html" => FileList["lib/**/*.rb", "README.mkd", "CHANGELOG"] do |filespec|
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

  desc "Build API documentation (doc/api)"
  task :api => "doc/api/index.html"

  desc "Creates/updates CHANGELOG file."
  task :changelog do |spec|
    historic = {}
    text     = ""

    log.scan(/(.*?);(.*?);(.*?);(.*?);/m) do |tag, date, subject, content|
      
      historic[date] = {
        :release => "#{date} #{tag.match(/(v\d\..*)/im) ? tag : nil}",
        :changes => []
      } unless historic.has_key? date

      historic[date][:changes] << "\n* #{subject}\n"
      historic[date][:changes] << content.gsub(/(.*?)\n/m){"\n  #{$1}\n"} unless content.empty?
    end

    historic.keys.sort.reverse.each do |date|
      entry = historic[date]
      puts "Adding historic from date #{date} ..."
      text  << <<-end_text.gsub(/^[ ]{8}/,'')
        #{entry[:release]}
        #{"-" * entry[:release].size}
        #{entry[:changes]}
      end_text
    end

    File.open("CHANGELOG", "w+") { |changelog| changelog << text }
    puts "Historic has #{historic.keys.size} entry dates"
    puts "Successfully updated CHANGELOG file"
  end

end

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

file package(".gem") => [ package_path.dirname, specfile ] do |file|
  sh "gem build #{specfile}"
  mv spec.file_name, file.prerequisites.first
end

file package(".tar.gz") => [ package_path, specfile ] do |file|
  spec.files.each do |source|
    package_path.join(source).dirname.mkpath
    cp source, package_path.join(source)
  end
  cd package_path.dirname
  sh "tar czvf #{package(".tar.gz").basename} #{package_path.basename}/*"
end

desc "Build packages."
task :package => [package(".gem"), package(".tar.gz")]

desc "Release gem package to repositories."
task :release => :package do
  news = File.read("v#{spec.version}.tag")
  sh "gem push #{package('.gem')}"
  sh "rubyforge add_release #{spec.name} #{spec.version} #{package('.gem')}"
  sh "rubyforge add_news 'Prigner v#{spec.version} released' '#{news}'"
end

desc "Install gem package #{spec.file_name}."
task :install => :package do
  sh "gem install #{package('.gem')} --local"
end

desc "Uninstall gem package #{spec.file_name}."
task :uninstall do
  sh "gem uninstall #{spec.name} --version #{spec.version}"
end

task :gem => :build

# Test
# =============================================================================

desc "Run tests."
task :test, [:pattern] do |spec, args|
  test(args[:pattern] ? "test/#{args[:pattern]}_test.rb" : "test/*_test.rb")
end

# Default
# =============================================================================

task :default => :test

