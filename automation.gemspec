# frozen_string_literal: true

require_relative "lib/automation/version"

Gem::Specification.new do |spec|
  spec.name        = "automation"
  spec.version     = Automation::VERSION
  spec.authors     = ["Floris Christiaansen"]
  spec.email       = ["floris@example.com"]
  spec.homepage    = "https://github.com/flori-s/automation"
  spec.summary     = "Time-based automation rules for Rails"
  spec.description = "Mountable Rails engine for JSON automation rules, relative-date scheduling, a DB-backed job sweep, and an ops dashboard."
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/flori-s/automation"
  spec.metadata["changelog_uri"] = "https://github.com/flori-s/automation/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 6.1.0"
end
