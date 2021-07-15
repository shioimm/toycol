# frozen_string_literal: true

require_relative "lib/toycol/version"

Gem::Specification.new do |spec|
  spec.name          = "toycol"
  spec.version       = Toycol::VERSION
  spec.authors       = ["Misaki Shioi"]
  spec.email         = ["shioi.mm@gmail.com"]

  spec.summary       = "Toy Application Protocol framework"
  spec.description   = "Toy Application Protocol framework"
  spec.homepage      = "https://github.com/shioimm/toycol"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/shioimm/toycol"
  spec.metadata["changelog_uri"] = "https://github.com/shioimm/toycol/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "puma"
  spec.add_dependency "rack", "~> 2.0"
end
