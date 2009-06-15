# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{subtrac}
  s.version = "0.1.59"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Keith Salisbury"]
  s.date = %q{2009-06-14}
  s.default_executable = %q{subtrac}
  s.email = %q{keithsalisbury@gmail.com}
  s.executables = ["subtrac"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.markdown"
  ]
  s.files = [
    ".document",
     ".gitignore",
     ".project",
     "LICENSE",
     "README.markdown",
     "Rakefile",
     "VERSION.yml",
     "bin/subtrac",
     "lib/subtrac.rb",
     "lib/subtrac/apache.rb",
     "lib/subtrac/apache/htgroups.erb",
     "lib/subtrac/apache/location.conf.erb",
     "lib/subtrac/apache/vhost.conf.erb",
     "lib/subtrac/client.rb",
     "lib/subtrac/commands.rb",
     "lib/subtrac/commands/create.rb",
     "lib/subtrac/commands/create_template.rb",
     "lib/subtrac/commands/delete.rb",
     "lib/subtrac/commands/install.rb",
     "lib/subtrac/commands/trac_admin.rb",
     "lib/subtrac/common/favicon.ico",
     "lib/subtrac/common/images/trac/banner_bg.jpg",
     "lib/subtrac/common/images/trac/bar_bg.gif",
     "lib/subtrac/common/images/trac/footer_back.png",
     "lib/subtrac/common/images/trac/main_bg.gif",
     "lib/subtrac/common/images/trac/saint_logo_small.png",
     "lib/subtrac/config.rb",
     "lib/subtrac/config/config.yml",
     "lib/subtrac/core_ext.rb",
     "lib/subtrac/core_ext/file.rb",
     "lib/subtrac/project.rb",
     "lib/subtrac/project/blank/svn/branches/README",
     "lib/subtrac/project/blank/svn/tags/README",
     "lib/subtrac/project/blank/svn/trunk/README",
     "lib/subtrac/project/blank/trac/wiki/WikiStart",
     "lib/subtrac/project/template/svn/trunk/svn/branches/README",
     "lib/subtrac/project/template/svn/trunk/svn/tags/README",
     "lib/subtrac/project/template/svn/trunk/svn/trunk/README",
     "lib/subtrac/project/template/svn/trunk/trac/wiki/WikiStart",
     "lib/subtrac/project/template/trac/wiki/WikiStart",
     "lib/subtrac/svn.rb",
     "lib/subtrac/svn/contrib/trac-post-commit-hook",
     "lib/subtrac/svn/post-commit.erb",
     "lib/subtrac/template.rb",
     "lib/subtrac/trac.rb",
     "lib/subtrac/trac/common.trac.ini.erb",
     "lib/subtrac/trac/trac.ini.erb",
     "lib/subtrac/version.rb",
     "subtrac.gemspec"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://ktec.subtrac.com/subtrac}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.2}
  s.summary = %q{Simple and opinionated helper for creating and managing subversion and trac projects.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<visionmedia-commander>, ["<= 3.2.9"])
    else
      s.add_dependency(%q<visionmedia-commander>, ["<= 3.2.9"])
    end
  else
    s.add_dependency(%q<visionmedia-commander>, ["<= 3.2.9"])
  end
end
