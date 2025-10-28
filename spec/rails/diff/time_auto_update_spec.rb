# frozen_string_literal: true

require "spec_helper"

RSpec.describe "RailsDiffTime Auto-update Feature" do
  let(:test_class) do
    Class.new do
      include RailsDiffTime::Helpers

      # Mock the render method to return the HTML structure
      def render(_template, locals:)
        element_name = locals[:element_name]
        diff_time = locals[:diff_time]
        attributes = locals[:attributes] || {}
        certain_time = locals[:certain_time]
        auto_update = locals[:auto_update]

        if auto_update
          attributes[:data] ||= {}
          attributes[:data][:diff_time_target] = "display"
          attributes[:data][:certain_time] = certain_time.iso8601
        end

        attrs_str = attributes.map do |key, value|
          if key == :data
            value.map { |k, v| "data-#{k.to_s.tr("_", "-")}=\"#{v}\"" }.join(" ")
          else
            "#{key}=\"#{value}\""
          end
        end.join(" ")

        "<#{element_name} #{attrs_str}>#{diff_time}</#{element_name}>"
      end

      # Mock javascript_tag helper
      def javascript_tag
        content = yield
        "<script>#{content}</script>"
      end
    end
  end

  let(:helper) { test_class.new }
  let(:now) { Time.parse("2025-10-19 12:00:00 UTC") }
  let(:certain_time) { now + 3600 } # 1 hour later

  before do
    allow(Time).to receive(:now).and_return(now)
  end

  describe "#diff_time with auto_update option" do
    context "when auto_update is true" do
      it "includes data-diff-time-target attribute" do
        result = helper.diff_time(certain_time, "span", {}, auto_update: true)
        expect(result).to include('data-diff-time-target="display"')
      end

      it "includes data-certain-time attribute with ISO8601 timestamp" do
        result = helper.diff_time(certain_time, "span", {}, auto_update: true)
        expect(result).to include("data-certain-time=\"#{certain_time.iso8601}\"")
      end

      it "includes JavaScript on first call" do
        result = helper.diff_time(certain_time, "span", {}, auto_update: true)
        expect(result).to include("<script>")
        expect(result).to include("DiffTimeUpdater")
      end

      it "does not include JavaScript on second call" do
        # First call - should include script
        first_result = helper.diff_time(certain_time, "span", {}, auto_update: true)
        expect(first_result).to include("<script>")

        # Second call - should NOT include script
        second_result = helper.diff_time(certain_time + 3600, "span", {}, auto_update: true)
        expect(second_result).not_to include("<script>")
      end

      it "works with custom element name" do
        result = helper.diff_time(certain_time, "div", {}, auto_update: true)
        expect(result).to start_with("<div")
        expect(result).to include('data-diff-time-target="display"')
      end

      it "preserves existing attributes" do
        result = helper.diff_time(
          certain_time,
          "span",
          { class: "timestamp", id: "my-time" },
          auto_update: true
        )
        expect(result).to include('class="timestamp"')
        expect(result).to include('id="my-time"')
        expect(result).to include('data-diff-time-target="display"')
      end
    end

    context "when auto_update is false or not specified" do
      it "does not include data-diff-time-target attribute" do
        result = helper.diff_time(certain_time, "span", {})
        expect(result).not_to include("data-diff-time-target")
      end

      it "does not include data-certain-time attribute" do
        result = helper.diff_time(certain_time, "span", {}, auto_update: false)
        expect(result).not_to include("data-certain-time")
      end

      it "does not include JavaScript" do
        result = helper.diff_time(certain_time, "span", {}, auto_update: false)
        expect(result).not_to include("<script>")
      end
    end
  end

  describe "JavaScript content" do
    it "includes DiffTimeUpdater class" do
      result = helper.diff_time(certain_time, "span", {}, auto_update: true)
      expect(result).to include("class DiffTimeUpdater")
    end

    it "includes Turbolinks/Turbo support" do
      result = helper.diff_time(certain_time, "span", {}, auto_update: true)
      expect(result).to include("turbolinks:load")
      expect(result).to include("turbo:load")
    end

    it "includes update interval configuration" do
      result = helper.diff_time(certain_time, "span", {}, auto_update: true)
      expect(result).to include("60000") # 60 seconds in milliseconds
    end
  end

  describe "data attribute format" do
    it "uses ISO8601 format for timestamp" do
      result = helper.diff_time(certain_time, "span", {}, auto_update: true)
      # ISO8601 format should include date, time, and timezone
      expect(result).to match(/data-certain-time="\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
    end

    it "works with past times" do
      past_time = now - 2.hours
      result = helper.diff_time(past_time, "span", {}, auto_update: true)
      expect(result).to include("data-certain-time=\"#{past_time.iso8601}\"")
      expect(result).to include("2 hours ago")
    end

    it "works with future times" do
      future_time = now + 3.days
      result = helper.diff_time(future_time, "span", {}, auto_update: true)
      expect(result).to include("data-certain-time=\"#{future_time.iso8601}\"")
      expect(result).to include("3 days later")
    end
  end
end
