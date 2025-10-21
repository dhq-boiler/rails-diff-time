# frozen_string_literal: true

require_relative "lib/rails/diff/time/version"

Gem::Specification.new do |spec|
  spec.name = "rails-diff-time"
  spec.version = RailsDiffTime::VERSION
  spec.authors = ["dhq_boiler"]
  spec.email = ["dhq_boiler@live.jp"]

  spec.summary = "Rails helper for displaying human-readable time differences with auto-update"
  spec.description = "A Rails gem that provides helper methods to display time differences in a human-readable format (e.g., '2 hours ago', '3 days later'). Features include auto-updating timestamps every minute without page reload, no JavaScript imports required, and seamless integration with Rails views. Supports various time units from seconds to years."
  spec.homepage = "https://github.com/dhq-boiler/rails-diff-time"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4.5"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

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
end