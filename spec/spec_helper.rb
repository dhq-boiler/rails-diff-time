# frozen_string_literal: true

require "time"
require "active_support"
require "active_support/inflector"
require "action_view"

# Conditionally load Rails engine parts
begin
  require "rails/engine"
rescue LoadError
  # Show warning or skip if Rails::Engine is not available
  puts "Warning: Rails::Engine not available in test environment"
end

# Load only the necessary parts for testing
require_relative "../lib/rails/diff/time/version"
require_relative "../lib/rails/diff/time/helpers"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
