require_relative "lib/bess/version"

Gem::Specification.new do |spec|
  spec.name        = "bess"
  spec.version     = Bess::VERSION
  spec.authors     = [""]
  spec.email       = ["eric@commitchange.com"]
  spec.homepage    = "https://houdiniproject.org"
  spec.summary     = "Support library for Houdini"
  spec.description = "Support library for Houdini"
  spec.license     = "AGPL-3.0-or-later WITH WTO-AP-3.0-or-later"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/houdiniproject/houdini"

  spec.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "AGPL-3.0.txt", "GPL-3.0.txt", "LGPL-3.0.txt", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.1.3"
  spec.add_dependency 'wisper', '~> 2.0'
  spec.add_dependency 'wisper-activejob', '~> 1.0.0'
  spec.add_dependency 'rest-client'

  spec.add_development_dependency 'rspec', '~> 3.13.0'
  spec.add_development_dependency 'rspec-rails', '~> 4.0.0'
  spec.add_development_dependency "concurrent-ruby", "1.3.4" # until Rails 7.1 becuase of the regression in concurrent-ruby


end
