Gem::Specification.new do |spec|
  spec.platform = Gem::Platform::RUBY

  #about
  spec.name = "prigner"
  spec.summary = "Project designer."
  spec.description = "Prigner is a Project Design Kit (a.k.a. project builder). That is, it is a tool which builds your projects using templates."
  spec.authors = ["Hallison Batista"]
  spec.email = "hallison@codigorama.com"
  spec.homepage = "http://codigorama.com/products/prigner"
  spec.rubyforge_project = spec.name
  spec.executables = [ "prign" ]
  spec.default_executable = "prign"
  #

  #version
  spec.version = "0.2.2"
  spec.date = "2010-11-17"
  #

  #dependencies
  #spec.add_dependency ""
  #

  #manifest
  spec.files = [
    "CHANGELOG",
    "COPYING",
    "README.rdoc",
    "Rakefile",
    "bin/prign",
    "doc/releases/v0.1.0.rdoc",
    "doc/releases/v0.1.1.rdoc",
    "doc/releases/v0.2.0.rdoc",
    "doc/releases/v0.2.1.rdoc",
    "doc/releases/v0.2.2.rdoc",
    "doc/templates.rdoc",
    "lib/prigner.rb",
    "lib/prigner/builder.rb",
    "lib/prigner/cli.rb",
    "lib/prigner/cli/copy.rb",
    "lib/prigner/cli/list.rb",
    "lib/prigner/cli/new.rb",
    "lib/prigner/extensions.rb",
    "lib/prigner/model.rb",
    "lib/prigner/project.rb",
    "lib/prigner/template.rb",
    "prigner.gemspec",
    "share/templates/bash/default/models/script.sh",
    "share/templates/bash/default/models/scriptrc",
    "share/templates/bash/default/specfile",
    "share/templates/ruby/default/models/CHANGELOG",
    "share/templates/ruby/default/models/COPYING",
    "share/templates/ruby/default/models/README.rdoc",
    "share/templates/ruby/default/models/executable",
    "share/templates/ruby/default/models/module.rb",
    "share/templates/ruby/default/models/testhelper.rb",
    "share/templates/ruby/default/specfile",
    "share/templates/ruby/gem/models/CHANGELOG",
    "share/templates/ruby/gem/models/COPYING",
    "share/templates/ruby/gem/models/README.rdoc",
    "share/templates/ruby/gem/models/Rakefile",
    "share/templates/ruby/gem/models/cli.rb",
    "share/templates/ruby/gem/models/executable",
    "share/templates/ruby/gem/models/gemspec",
    "share/templates/ruby/gem/models/module.rb",
    "share/templates/ruby/gem/models/testhelper.rb",
    "share/templates/ruby/gem/specfile",
    "share/templates/ruby/sinatra/models/CHANGELOG",
    "share/templates/ruby/sinatra/models/LICENSE",
    "share/templates/ruby/sinatra/models/README.rdoc",
    "share/templates/ruby/sinatra/models/Rakefile",
    "share/templates/ruby/sinatra/models/application.rb",
    "share/templates/ruby/sinatra/models/cli.rb",
    "share/templates/ruby/sinatra/models/config.ru",
    "share/templates/ruby/sinatra/models/executable",
    "share/templates/ruby/sinatra/models/gemspec",
    "share/templates/ruby/sinatra/models/module.rb",
    "share/templates/ruby/sinatra/models/mvc/config.rb",
    "share/templates/ruby/sinatra/models/mvc/controller.rb",
    "share/templates/ruby/sinatra/models/mvc/database.yml",
    "share/templates/ruby/sinatra/models/mvc/model.rb",
    "share/templates/ruby/sinatra/models/mvc/view.erb",
    "share/templates/ruby/sinatra/models/testhelper.rb",
    "share/templates/ruby/sinatra/specfile",
    "test/builder_test.rb",
    "test/fixtures/model.rb.erb",
    "test/fixtures/templates/shared/templates/ruby/default/models/README.mkd",
    "test/fixtures/templates/shared/templates/ruby/default/models/Rakefile",
    "test/fixtures/templates/shared/templates/ruby/default/models/cli.rb",
    "test/fixtures/templates/shared/templates/ruby/default/models/empty_test.rb",
    "test/fixtures/templates/shared/templates/ruby/default/models/executable",
    "test/fixtures/templates/shared/templates/ruby/default/models/module.rb",
    "test/fixtures/templates/shared/templates/ruby/default/models/testhelper.rb",
    "test/fixtures/templates/shared/templates/ruby/default/specfile",
    "test/fixtures/templates/shared/templates/ruby/sinatra/models/README.mkd",
    "test/fixtures/templates/shared/templates/ruby/sinatra/models/Rakefile",
    "test/fixtures/templates/shared/templates/ruby/sinatra/models/empty_test.rb",
    "test/fixtures/templates/shared/templates/ruby/sinatra/models/module.rb",
    "test/fixtures/templates/shared/templates/ruby/sinatra/specfile",
    "test/fixtures/templates/user/.prigner/sources",
    "test/fixtures/templates/user/.prigner/templates/bash/default/specfile",
    "test/fixtures/templates/user/.prigner/templates/ruby/program/models/README.erb",
    "test/fixtures/templates/user/.prigner/templates/ruby/program/models/cli.rb.erb",
    "test/fixtures/templates/user/.prigner/templates/ruby/program/models/module.rb.erb",
    "test/fixtures/templates/user/.prigner/templates/ruby/program/models/program.rb.erb",
    "test/fixtures/templates/user/.prigner/templates/ruby/program/specfile",
    "test/fixtures/templates/user/.prigner/templates/vim/default/specfile",
    "test/fixtures/templates/user/.prigner/templates/vim/plugin/specfile",
    "test/fixtures/templates/user/.prigner/templates/vim/syntax/specfile",
    "test/helpers.rb",
    "test/model_test.rb",
    "test/project_test.rb",
    "test/spec_test.rb",
    "test/template_test.rb"
  ]
  #

  spec.test_files = spec.files.select{ |path| path =~ /^test\/*test*/ }

  spec.require_paths = ["lib"]

  #documentation
  spec.has_rdoc = true
  spec.extra_rdoc_files = [
    "README.rdoc",
    "COPYING",
    "CHANGELOG"
  ]
  spec.rdoc_options = [
    "--inline-source",
    "--line-numbers",
    "--charset", "utf8",
    "--main", "Prigner",
    "--title", "Prigner v#{spec.version} API Documentation"
  ]

  spec.post_install_message = <<-end_message.gsub(/^[ ]{4}/,'')
    #{'-'*78}
    Prigner v#{spec.version}

    Thanks for use Prigner. See all shared templates running:

    $ prign list
    #{'-'*78}
  end_message
  #
end

