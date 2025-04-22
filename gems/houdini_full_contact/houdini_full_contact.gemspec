require_relative "lib/houdini_full_contact/version"

Gem::Specification.new do |spec|
  spec.name = "houdini_full_contact"
  spec.version = HoudiniFullContact::VERSION
  spec.authors = [""]
  spec.email = ["eric@commitchange.com"]
  # spec.homepage    = "TODO"
  spec.summary = " Summary of FullContact."
  # spec.description = "TODO: Description of FullContact."
  spec.license = "AGPL-3.0-or-later WITH WTO-Additional-Permission-3.0-or-later"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "AGPL-3.0.txt", "GPL-3.0.txt", "LGPL-3.0.txt", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.1"
  spec.add_dependency "qx"
  spec.add_dependency "bess"
end
