Gem::Specification.new do |spec|
  spec.platform = Gem::Platform::RUBY

  #about
  spec.name = "rubify"
  spec.summary = "Ruby template engine."
  spec.description = "Rubify is a template engine for Ruby projects."
  spec.authors = ["Hallison Batista"]
  spec.email = "hallison.batista@gmail.com"
  spec.homepage = "http://codigorama.com/produtos/rubify"
  #

  #version
  spec.version = "0.1.0"
  spec.date = "2009-07-16"
  #

  #dependencies
  #spec.add_dependency ""
  #

  #manifest
  spec.files = [
    "CHANGELOG",
    "COPYING",
    "README.mkd",
    "Rakefile",
    "lib/rubify.rb",
    "lib/rubify/extensions.rb",
    "lib/rubify/project.rb",
    "lib/rubify/template.rb",
    "rubify.gemspec",
    "test/fixtures/project/foo/bin/foo",
    "test/fixtures/project/foo/config/foo.yml",
    "test/fixtures/project/foo/test/foo_test.rb",
    "test/fixtures/templates/foo.rb",
    "test/fixtures/templates/foo.rb.erb",
    "test/helpers.rb",
    "test/project_test.rb",
    "test/template_test.rb"
  ]
  #

  spec.test_files = spec.files.select{ |path| path =~ /^test\/*test*/ }

  spec.require_paths = ["lib"]

  #documentation
  spec.has_rdoc = true
  spec.extra_rdoc_files = [
    "README.mkd",
    "COPYING",
    "CHANGELOG"
  ]
  spec.rdoc_options = [
    "--inline-source",
    "--line-numbers",
    "--charset", "utf8",
    "--main", "Rubify",
    "--title", "Rubify API Documentation"
  ]

  #rubygems
  spec.rubyforge_project = spec.name
  spec.post_install_message = <<-end_message.gsub(/^[ ]{4}/,'')
    #{'-'*78}
    Rubify v#{spec.version}

    Thanks for use Rubify.

    Please, feedback in http://codigorama.com/rubify/issues.
    #{'-'*78}
  end_message
  #
end

