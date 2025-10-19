# frozen_string_literal: true

require_relative "lib/rails/diff/time/version"

Gem::Specification.new do |spec|
  spec.name = "rails-diff-time"
  spec.version = RailsDiffTime::VERSION
  spec.authors = ["dhq_boiler"]
  spec.email = ["dhq_boiler@live.jp"]

  spec.summary = "Rails helper for displaying human-readable time differences"
  spec.description = "A Rails gem that provides helper methods to display time differences in a human-readable format (e.g., '2 hours ago', '3 days later'). Integrates seamlessly with Rails views and supports various time units from seconds to years."
  spec.homepage = "https://github.com/dhq-boiler/rails-diff-time"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4.5"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
