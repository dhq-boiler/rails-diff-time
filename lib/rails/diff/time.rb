# frozen_string_literal: true

require_relative "time/version"
require_relative "time/helpers"

module Rails
  module Diff
    module Time
      class Error < StandardError; end

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
