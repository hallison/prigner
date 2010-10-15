$LOAD_PATH.unshift(File.join(File.dirname(__FILE__)))

require "rake/clean"
require "lib/prigner"

# Helpers
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

def manifest
  @manifest ||= `git ls-files`.split("\n").sort.reject do |out|
    out =~ /^\./ || out =~ /^doc/
  end.map do |file|
    "    #{file.inspect}"
  end.join(",\n")
end

def log
  @log ||= `git log --date=short --format='%d;%cd;%s;%b;'`
end

def version
  @version ||= Prigner.version
end

def gemspec
  @gemspec ||= Struct.new(:spec, :file).new
  @gemspec.file ||= Pathname.new("prigner.gemspec")
  @gemspec.spec ||= eval @gemspec.file.read
  @gemspec
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

namespace :version do

  major, minor, patch, build = version.tag.split(".").map{ |key| key.to_i } << 0

  desc "Dump major version"
  task :major do
    version.tag = "#{major+=1}.0.0"
    version.save!
    puts version.to_hash.to_yaml
  end

  desc "Dump minor version"
  task :minor do
    version.tag = "#{major}.#{minor+=1}.0"
    version.save!
    puts version.to_hash.to_yaml
  end

  desc "Dump patch version"
  task :patch do
    version.tag = "#{major}.#{minor}.#{patch+=1}"
    version.save!
    puts version.to_hash.to_yaml
  end

  desc "Dump build version"
  task :build do
    version.tag = "#{major}.#{minor}.#{patch}.#{build+=1}"
    version.save!
    puts version.to_hash.to_yaml
  end

  desc "Update version date (current #{version.date})"
  task :date, [:date] do |spec, args|
    require "parsedate"
    require "date"
    yyyy, mm, dd = ParseDate.parsedate(args[:date]).compact if args[:date]
    version.date = (yyyy && mm && dd) ? Date.new(yyyy, mm, dd) : Date.today
    version.save!
    puts version.to_hash.to_yaml
  end
end

task :version => "version:build"

# RubyGems
# =============================================================================

namespace :gem do

  file gemspec.file => FileList["{lib,test}/**", "Rakefile"] do
    spec = gemspec.file.read

    puts "Updating version ..."
      spec.sub! /spec\.version\s*=\s*".*?"/,  "spec.version = #{version.tag.inspect}"

    puts "Updating date of version ..."
      spec.sub! /spec\.date\s*=\s*".*?"/,     "spec.date = #{version.date.to_s.inspect}"

    puts "Updating file list ..."
      spec.sub! /spec\.files\s*=\s*\[.*?\]/m, "spec.files = [\n#{manifest}\n  ]"

    gemspec.file.open("w+") { |file| file << spec }

    puts "Successfully update #{gemspec.file} file"
  end

  desc "Build gem package #{gemspec.spec.file_name}"
  task :build => gemspec.file do
    sh "gem build #{gemspec.file}"
  end

  desc "Deploy gem package to RubyGems.org"
  task :deploy => :build do
    sh "gem push #{gemspec.spec.file_name}"
  end

  desc "Install gem package #{gemspec.spec.file_name}"
  task :install => :build do
    sh "gem install #{gemspec.spec.file_name} --local"
  end

  desc "Uninstall gem package #{gemspec.spec.file_name}"
  task :uninstall do
    sh "gem uninstall #{gemspec.spec.name} --version #{gemspec.spec.version}"
  end

end

task :gem => "gem:build"

# Test
# =============================================================================

desc "Run tests"
task :test, [:pattern] do |spec, args|
  test(args[:pattern] ? "test/#{args[:pattern]}_test.rb" : "test/*_test.rb")
end

# Default
# =============================================================================

task :default => "test"

