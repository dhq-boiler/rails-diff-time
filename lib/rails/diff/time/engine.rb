# frozen_string_literal: true

module RailsDiffTime
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
