# frozen_string_literal: true

require_relative "time/version"
require_relative "time/helpers"
require_relative "time/engine" if defined?(Rails)

module RailsDiffTime
  class Error < StandardError; end
end
