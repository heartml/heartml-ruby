# frozen_string_literal: true

require_relative "lib/heartml/version"

Gem::Specification.new do |spec|
  spec.name = "heartml"
  spec.version = Heartml::VERSION
  spec.authors = ["Jared White"]
  spec.email = ["jared@whitefusion.studio"]

  spec.summary = "Server-rendered web components"
  spec.homepage = "https://github.com/heartml/heartml-ruby#readme"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/heartml/heartml-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/heartml/heartml-ruby/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "concurrent-ruby", "~> 1.2"
  spec.add_dependency "nokolexbor", ">= 0.4.2"

  spec.add_development_dependency "hash_with_dot_access", "~> 1.2"
end
