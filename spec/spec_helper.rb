# frozen_string_literal: true

require "time"
require "active_support"
require "active_support/inflector"
require "action_view"

# Railsエンジンの部分を条件付きで読み込み
begin
  require "rails/engine"
rescue LoadError
  # Rails::Engineが利用できない場合は警告を出すか、スキップする
  puts "Warning: Rails::Engine not available in test environment"
end

# テスト用に必要な部分のみ読み込み
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
