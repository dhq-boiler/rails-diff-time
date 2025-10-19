# frozen_string_literal: true

require_relative "time/version"
require_relative "time/helpers"

module RailsDiffTime
  class Error < StandardError; end

  # Define Engine class only when Rails::Engine is available
  if defined?(::Rails::Engine)
    # Rails engine for integrating RailsDiffTime into Rails applications.
    #
    # This engine automatically includes the time difference helpers into
    # ActionView, making them available in all views and templates.
    class Engine < ::Rails::Engine
      isolate_namespace RailsDiffTime

      initializer "rails_diff_time.helpers" do
        ActiveSupport.on_load(:action_view) do
          include RailsDiffTime::Helpers
        end
      end
    end
  end
end
