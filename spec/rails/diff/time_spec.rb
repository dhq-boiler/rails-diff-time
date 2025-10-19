# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsDiffTime do
  it "has a version number" do
    expect(RailsDiffTime::VERSION).not_to be nil
  end
end

RSpec.describe RailsDiffTime::Helpers do
  # Create a dummy class for testing
  let(:test_class) do
    Class.new do
      include RailsDiffTime::Helpers

      # Mock the render method
      def render(_template, locals:)
        "#{locals[:element_name]}: #{locals[:diff_time]}"
      end
    end
  end

  let(:helper) { test_class.new }
  let(:now) { Time.parse("2025-10-19 12:00:00 UTC") }

  before do
    allow(Time).to receive(:now).and_return(now)
  end

  describe "#diff_time" do
    it "renders the diff_time partial with correct locals" do
      certain_time = now + 3600 # 1 hour later
      result = helper.diff_time(certain_time)
      expect(result).to eq("span: 1 hour later")
    end

    it "accepts custom element_name and attributes" do
      certain_time = now + 3600
      result = helper.diff_time(certain_time, "div", { class: "time-diff" })
      expect(result).to eq("div: 1 hour later")
    end
  end

  describe "#diff_time_str" do
    context "when time is in the future" do
      it "shows seconds later" do
        certain_time = now + 30 # 30 seconds later
        expect(helper.send(:diff_time_str, certain_time)).to eq("30 seconds later")
      end

      it "shows 'now' for 1 second later (within 5 second threshold)" do
        certain_time = now + 1 # 1 second later
        expect(helper.send(:diff_time_str, certain_time)).to eq("now")
      end

      it "shows minutes and seconds later" do
        certain_time = now + 90 # 1 minute 30 seconds later
        expect(helper.send(:diff_time_str, certain_time)).to eq("1 minute 30 seconds later")
      end

      it "shows minutes later (no remaining seconds)" do
        certain_time = now + 120 # 2 minutes later
        expect(helper.send(:diff_time_str, certain_time)).to eq("2 minutes later")
      end

      it "shows hours and minutes later" do
        certain_time = now + 3900 # 1 hour 5 minutes later
        expect(helper.send(:diff_time_str, certain_time)).to eq("1 hour 5 minutes later")
      end

      it "shows hours later (no remaining minutes)" do
        certain_time = now + 7200 # 2 hours later
        expect(helper.send(:diff_time_str, certain_time)).to eq("2 hours later")
      end

      it "shows days later" do
        certain_time = now + 86_400 # 1 day later
        expect(helper.send(:diff_time_str, certain_time)).to eq("1 day later")
      end

      it "shows weeks later" do
        certain_time = now + 604_800 # 1 week later
        expect(helper.send(:diff_time_str, certain_time)).to eq("1 week later")
      end

      it "shows months and days later" do
        certain_time = now + 2_678_400 # 31 days later (1 month and 1 day)
        expect(helper.send(:diff_time_str, certain_time)).to eq("1 month 1 day later")
      end

      it "shows months later (no remaining days)" do
        certain_time = now + 2_592_000 # 30 days later (1 month)
        expect(helper.send(:diff_time_str, certain_time)).to eq("1 month later")
      end

      it "shows years later" do
        certain_time = now + 31_557_600 # 1 year later (365.25 days)
        expect(helper.send(:diff_time_str, certain_time)).to eq("1 year later")
      end

      it "shows years, months, and days later" do
        certain_time = now + (365.25 * 24 * 3600) + (30 * 24 * 3600) + (24 * 3600) # 1 year 1 month 1 day later
        expect(helper.send(:diff_time_str, certain_time)).to eq("1 year 1 month 1 day later")
      end
    end

    context "when time is in the past" do
      it "shows seconds ago" do
        certain_time = now - 30 # 30 seconds ago
        expect(helper.send(:diff_time_str, certain_time)).to eq("30 seconds ago")
      end

      it "shows 'now' for 1 second ago (within 5 second threshold)" do
        certain_time = now - 1 # 1 second ago
        expect(helper.send(:diff_time_str, certain_time)).to eq("now")
      end

      it "shows minutes and seconds ago" do
        certain_time = now - 90 # 1 minute 30 seconds ago
        expect(helper.send(:diff_time_str, certain_time)).to eq("1 minute 30 seconds ago")
      end

      it "shows hours ago" do
        certain_time = now - 3600 # 1 hour ago
        expect(helper.send(:diff_time_str, certain_time)).to eq("1 hour ago")
      end

      it "shows days ago" do
        certain_time = now - 86_400 # 1 day ago
        expect(helper.send(:diff_time_str, certain_time)).to eq("1 day ago")
      end

      it "shows weeks ago" do
        certain_time = now - 604_800 # 1 week ago
        expect(helper.send(:diff_time_str, certain_time)).to eq("1 week ago")
      end

      it "shows months ago" do
        certain_time = now - 2_592_000 # 1 month ago
        expect(helper.send(:diff_time_str, certain_time)).to eq("1 month ago")
      end

      it "shows years ago" do
        certain_time = now - 31_557_600 # 1 year ago
        expect(helper.send(:diff_time_str, certain_time)).to eq("1 year ago")
      end
    end

    context "edge cases" do
      it "shows 'now' for time differences within 5 seconds (future)" do
        certain_time = now + 3 # 3 seconds later
        expect(helper.send(:diff_time_str, certain_time)).to eq("now")
      end

      it "shows 'now' for time differences within 5 seconds (past)" do
        certain_time = now - 4 # 4 seconds ago
        expect(helper.send(:diff_time_str, certain_time)).to eq("now")
      end

      it "shows 'now' for exactly 5 seconds difference" do
        certain_time = now + 5 # exactly 5 seconds later
        expect(helper.send(:diff_time_str, certain_time)).to eq("now")
      end

      it "shows 'now' for exactly now" do
        certain_time = now
        expect(helper.send(:diff_time_str, certain_time)).to eq("now")
      end

      it "shows seconds for time differences over 5 seconds" do
        certain_time = now + 6 # 6 seconds later
        expect(helper.send(:diff_time_str, certain_time)).to eq("6 seconds later")
      end

      it "handles pluralization correctly" do
        # Test for pluralization (project-specific logic)
        certain_time = now + 10 # 10 seconds later
        expect(helper.send(:diff_time_str, certain_time)).to eq("10 seconds later")
      end
    end
  end

  describe "private helper methods" do
    describe "#ago_or_later" do
      it "returns 'ago' for negative diff" do
        expect(helper.send(:ago_or_later, -100)).to eq("ago")
      end

      it "returns 'later' for positive diff" do
        expect(helper.send(:ago_or_later, 100)).to eq("later")
      end

      it "returns 'later' for zero diff" do
        expect(helper.send(:ago_or_later, 0)).to eq("later")
      end
    end

    describe "#time_str" do
      it "returns singular form for count 1" do
        expect(helper.send(:time_str, 1, "hour")).to eq("1 hour")
      end

      it "returns plural form for count > 1" do
        expect(helper.send(:time_str, 2, "hour")).to eq("2 hours")
      end

      it "returns plural form for count 0" do
        expect(helper.send(:time_str, 0, "hour")).to eq("0 hours")
      end
    end
  end

  describe "format methods" do
    let(:diff_future) { 100 }
    let(:diff_past) { -100 }

    describe "#format_seconds" do
      it "formats seconds correctly" do
        result = helper.send(:format_seconds, 45, diff_future)
        expect(result).to eq("45 seconds later")
      end
    end

    describe "#format_minutes" do
      it "formats minutes only" do
        result = helper.send(:format_minutes, 120, diff_future)
        expect(result).to eq("2 minutes later")
      end

      it "formats minutes with remaining seconds" do
        result = helper.send(:format_minutes, 150, diff_future)
        expect(result).to eq("2 minutes 30 seconds later")
      end
    end

    describe "#format_hours" do
      it "formats hours only" do
        result = helper.send(:format_hours, 7200, diff_future)
        expect(result).to eq("2 hours later")
      end

      it "formats hours with remaining minutes" do
        result = helper.send(:format_hours, 9000, diff_future)
        expect(result).to eq("2 hours 30 minutes later")
      end
    end

    describe "#format_days" do
      it "formats days correctly" do
        result = helper.send(:format_days, 172_800, diff_future)
        expect(result).to eq("2 days later")
      end
    end

    describe "#format_weeks" do
      it "formats weeks correctly" do
        result = helper.send(:format_weeks, 1_209_600, diff_future)
        expect(result).to eq("2 weeks later")
      end
    end

    describe "#format_months" do
      it "formats months only" do
        result = helper.send(:format_months, 5_184_000, diff_future)
        expect(result).to eq("2 months later")
      end

      it "formats months with remaining days" do
        result = helper.send(:format_months, 5_270_400, diff_future)
        expect(result).to eq("2 months 1 day later")
      end
    end

    describe "#format_years" do
      it "formats years only" do
        result = helper.send(:format_years, 63_115_200, diff_future)
        expect(result).to eq("2 years later")
      end

      it "formats years with months and days" do
        # 2 years + 1 month + 1 day
        seconds = (2 * 365.25 * 24 * 3600) + (30 * 24 * 3600) + (24 * 3600)
        result = helper.send(:format_years, seconds, diff_future)
        expect(result).to eq("2 years 1 month 1 day later")
      end
    end
  end
end
