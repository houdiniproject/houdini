require_relative "lib/houdini_upgrade/version"

Gem::Specification.new do |spec|
  spec.name = "houdini_upgrade"
  spec.version = HoudiniUpgrade::VERSION
  spec.authors = ["The Houdini Project"]
  spec.email = [""]
  spec.homepage = "https://houdiniproject.org"
  spec.summary = ""
  spec.description = ""
  spec.license = "AGPL-3.0-or-later WITH WTO-AP-3.0-or-later"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = ""
  # spec.metadata["changelog_uri"] = ""

  spec.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "AGPL-3.0.txt", "GPL-3.0.txt", "LGPL-3.0.txt", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.1"
end
