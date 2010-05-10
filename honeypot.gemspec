# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{honeypot}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Seamus Abshere"]
  s.date = %q{2010-05-10}
  s.description = %q{Catch bad guys when they stick their hands in the honey.}
  s.email = %q{seamus@abshere.net}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "honeypot.gemspec",
     "lib/honeypot.rb",
     "lib/honeypot/ipaddr_ext.rb",
     "lib/honeypot/rack.rb",
     "lib/honeypot/railtie.rb",
     "lib/remote_host.rb",
     "lib/remote_request.rb",
     "test/helper.rb",
     "test/test_honeypot.rb"
  ]
  s.homepage = %q{http://github.com/seamusabshere/honeypot}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Track remote requests to catch fraud.}
  s.test_files = [
    "test/helper.rb",
     "test/test_honeypot.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<fast_timestamp>, [">= 0.0.4"])
      s.add_runtime_dependency(%q<geokit>, [">= 1.5.0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 3.0.0beta2"])
      s.add_runtime_dependency(%q<activerecord>, [">= 3.0.0beta2"])
    else
      s.add_dependency(%q<fast_timestamp>, [">= 0.0.4"])
      s.add_dependency(%q<geokit>, [">= 1.5.0"])
      s.add_dependency(%q<activesupport>, [">= 3.0.0beta2"])
      s.add_dependency(%q<activerecord>, [">= 3.0.0beta2"])
    end
  else
    s.add_dependency(%q<fast_timestamp>, [">= 0.0.4"])
    s.add_dependency(%q<geokit>, [">= 1.5.0"])
    s.add_dependency(%q<activesupport>, [">= 3.0.0beta2"])
    s.add_dependency(%q<activerecord>, [">= 3.0.0beta2"])
  end
end

