# frozen_string_literal: true

require_relative "time/version"
require_relative "time/helpers"

module Rails
  module Diff
    # Rails::Diff::Time provides helper methods for displaying time differences
    # in a human-readable format within Rails applications.
    #
    # This module includes functionality to format time differences as relative
    # strings (e.g., "2 hours ago", "3 days later") and integrates seamlessly
    # with Rails views through helper methods.
    module Time
      class Error < StandardError; end

      # Define Engine class only when Rails::Engine is available
      if defined?(::Rails::Engine)
        # Rails engine for integrating Rails::Diff::Time into Rails applications.
        #
        # This engine automatically includes the time difference helpers into
        # ActionView, making them available in all views and templates.
        class Engine < ::Rails::Engine
          isolate_namespace Rails::Diff::Time

          initializer "rails_diff_time.helpers" do
            ActiveSupport.on_load(:action_view) do
              include Rails::Diff::Time::Helpers
            end
          end
        end
      end
    end
  end
end
