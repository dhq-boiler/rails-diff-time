# frozen_string_literal: true

module RailsDiffTime
  # Helper methods for displaying time differences in a human-readable format.
  module Helpers
    def diff_time(certain_time, element_name = "span", attributes = {}, auto_update: false)
      return "" if certain_time.nil?

      result = render "rails-diff-time/diff_time", locals: {
        diff_time: diff_time_str(certain_time),
        element_name: element_name,
        attributes: attributes,
        certain_time: certain_time,
        auto_update: auto_update
      }

      # If auto_update is enabled and the script has not been included yet
      if auto_update && !@_diff_time_script_included
        @_diff_time_script_included = true
        result += diff_time_script_tag
      end

      result
    end

    private

    def diff_time_script_tag
      javascript_tag do
        <<~JAVASCRIPT.html_safe
          (function() {
            'use strict';

            class DiffTimeUpdater {
              constructor() {
                this.updateInterval = 60000;
                this.elements = [];
                this.timerId = null;
              }

              init() {
                this.findElements();
                if (this.elements.length > 0) {
                  this.startAutoUpdate();
                }
              }

              findElements() {
                this.elements = Array.from(
                  document.querySelectorAll('[data-diff-time-target="display"]')
                );
              }

              startAutoUpdate() {
                if (this.timerId) clearInterval(this.timerId);
                this.timerId = setInterval(() => this.updateAll(), this.updateInterval);
              }

              updateAll() {
                this.elements.forEach(element => this.updateElement(element));
              }

              updateElement(element) {
                const certainTimeStr = element.dataset.certainTime;
                if (!certainTimeStr) return;
                const certainTime = new Date(certainTimeStr);
                const diffTimeStr = this.calculateDiffTime(certainTime);
                element.textContent = diffTimeStr;
              }

              calculateDiffTime(certainTime) {
                const now = new Date();
                const diff = certainTime - now;
                const differenceInSeconds = Math.abs(diff) / 1000;

                if (differenceInSeconds <= 5) return "now";

                const isLater = diff > 0;

                if (differenceInSeconds >= this.yearInSeconds()) {
                  return this.formatYears(differenceInSeconds, isLater);
                } else if (differenceInSeconds >= this.monthInSeconds()) {
                  return this.formatMonths(differenceInSeconds, isLater);
                } else if (differenceInSeconds >= this.weekInSeconds()) {
                  return this.formatWeeks(differenceInSeconds, isLater);
                } else if (differenceInSeconds >= this.dayInSeconds()) {
                  return this.formatDays(differenceInSeconds, isLater);
                } else if (differenceInSeconds >= this.hourInSeconds()) {
                  return this.formatHours(differenceInSeconds, isLater);
                } else if (differenceInSeconds >= this.minuteInSeconds()) {
                  return this.formatMinutes(differenceInSeconds, isLater);
                } else {
                  return this.formatSeconds(differenceInSeconds, isLater);
                }
              }

              formatYears(seconds, isLater) {
                const years = Math.floor(seconds / this.yearInSeconds());
                let remaining = seconds - (years * this.yearInSeconds());
                let result = this.timeStr(years, "year");

                if (remaining >= this.monthInSeconds()) {
                  const months = Math.floor(remaining / this.monthInSeconds());
                  remaining -= months * this.monthInSeconds();
                  result += ` ${this.timeStr(months, "month")}`;

                  if (remaining >= this.dayInSeconds()) {
                    const days = Math.floor(remaining / this.dayInSeconds());
                    result += ` ${this.timeStr(days, "day")}`;
                  }
                }
                return `${result} ${this.agoOrLater(isLater)}`;
              }

              formatMonths(seconds, isLater) {
                const months = Math.floor(seconds / this.monthInSeconds());
                const remaining = seconds - (months * this.monthInSeconds());
                let result = this.timeStr(months, "month");

                if (remaining >= this.dayInSeconds()) {
                  const days = Math.floor(remaining / this.dayInSeconds());
                  result += ` ${this.timeStr(days, "day")}`;
                }
                return `${result} ${this.agoOrLater(isLater)}`;
              }

              formatWeeks(seconds, isLater) {
                const weeks = Math.floor(seconds / this.weekInSeconds());
                return `${this.timeStr(weeks, "week")} ${this.agoOrLater(isLater)}`;
              }

              formatDays(seconds, isLater) {
                const days = Math.floor(seconds / this.dayInSeconds());
                return `${this.timeStr(days, "day")} ${this.agoOrLater(isLater)}`;
              }

              formatHours(seconds, isLater) {
                const hours = Math.floor(seconds / this.hourInSeconds());
                const remaining = seconds - (hours * this.hourInSeconds());
                let result = this.timeStr(hours, "hour");

                if (remaining >= this.minuteInSeconds()) {
                  const minutes = Math.floor(remaining / this.minuteInSeconds());
                  result += ` ${this.timeStr(minutes, "minute")}`;
                }
                return `${result} ${this.agoOrLater(isLater)}`;
              }

              formatMinutes(seconds, isLater) {
                const minutes = Math.floor(seconds / this.minuteInSeconds());
                const remaining = seconds - (minutes * this.minuteInSeconds());
                let result = this.timeStr(minutes, "minute");

                if (remaining > 0) {
                  const secs = Math.floor(remaining);
                  result += ` ${this.timeStr(secs, "second")}`;
                }
                return `${result} ${this.agoOrLater(isLater)}`;
              }

              formatSeconds(seconds, isLater) {
                const secs = Math.floor(seconds);
                return `${this.timeStr(secs, "second")} ${this.agoOrLater(isLater)}`;
              }

              yearInSeconds() { return 365.25 * 24 * 3600; }
              monthInSeconds() { return 30 * 24 * 3600; }
              weekInSeconds() { return 7 * 24 * 3600; }
              dayInSeconds() { return 24 * 3600; }
              hourInSeconds() { return 3600; }
              minuteInSeconds() { return 60; }

              agoOrLater(isLater) { return isLater ? "later" : "ago"; }

              timeStr(count, singular) {
                const plural = singular + "s";
                return `${count} ${count === 1 ? singular : plural}`;
              }

              destroy() {
                if (this.timerId) {
                  clearInterval(this.timerId);
                  this.timerId = null;
                }
                this.elements = [];
              }
            }

            let updater = null;

            function initUpdater() {
              if (updater) updater.destroy();
              updater = new DiffTimeUpdater();
              updater.init();
            }

            if (document.readyState === 'loading') {
              document.addEventListener('DOMContentLoaded', initUpdater);
            } else {
              initUpdater();
            }

            document.addEventListener('turbolinks:load', initUpdater);
            document.addEventListener('turbo:load', initUpdater);

            document.addEventListener('turbolinks:before-cache', function() {
              if (updater) updater.destroy();
            });

            document.addEventListener('turbo:before-cache', function() {
              if (updater) updater.destroy();
            });

            window.RailsDiffTime = {
              updater: updater,
              DiffTimeUpdater: DiffTimeUpdater
            };
          })();
        JAVASCRIPT
      end
    end

    def diff_time_str(certain_time)
      now = ::Time.now
      diff = certain_time - now
      difference_in_seconds = diff.abs

      return "now" if difference_in_seconds <= 5

      case difference_in_seconds
      when year_threshold..Float::INFINITY
        format_years difference_in_seconds, diff
      when month_threshold...year_threshold
        format_months difference_in_seconds, diff
      when week_threshold...month_threshold
        format_weeks difference_in_seconds, diff
      when day_threshold...week_threshold
        format_days difference_in_seconds, diff
      when hour_threshold...day_threshold
        format_hours difference_in_seconds, diff
      when minute_threshold...hour_threshold
        format_minutes difference_in_seconds, diff
      else
        format_seconds difference_in_seconds, diff
      end
    end

    def format_years(difference_in_seconds, diff)
      years = (difference_in_seconds / year_in_seconds).floor
      remaining_seconds = difference_in_seconds - (years * year_in_seconds)

      if remaining_seconds >= month_in_seconds
        months = (remaining_seconds / month_in_seconds).floor
        remaining_seconds -= months * month_in_seconds

        if remaining_seconds >= day_in_seconds
          days = (remaining_seconds / day_in_seconds).floor
          "#{time_str(years, "year")} #{time_str(months, "month")} #{time_str(days, "day")} #{ago_or_later(diff)}"
        else
          "#{time_str(years, "year")} #{time_str(months, "month")} #{ago_or_later(diff)}"
        end
      else
        "#{time_str(years, "year")} #{ago_or_later(diff)}"
      end
    end

    def format_months(difference_in_seconds, diff)
      months = (difference_in_seconds / month_in_seconds).floor
      remaining_seconds = difference_in_seconds - (months * month_in_seconds)

      if remaining_seconds >= day_in_seconds
        days = (remaining_seconds / day_in_seconds).floor
        "#{time_str(months, "month")} #{time_str(days, "day")} #{ago_or_later(diff)}"
      else
        "#{time_str(months, "month")} #{ago_or_later(diff)}"
      end
    end

    def format_weeks(difference_in_seconds, diff)
      weeks = (difference_in_seconds / week_in_seconds).floor
      "#{time_str(weeks, "week")} #{ago_or_later(diff)}"
    end

    def format_days(difference_in_seconds, diff)
      days = (difference_in_seconds / day_in_seconds).floor
      "#{time_str(days, "day")} #{ago_or_later(diff)}"
    end

    def format_hours(difference_in_seconds, diff)
      hours = (difference_in_seconds / hour_in_seconds).floor
      remaining_seconds = difference_in_seconds - (hours * hour_in_seconds)

      if remaining_seconds >= minute_in_seconds
        minutes = (remaining_seconds / minute_in_seconds).floor
        "#{time_str(hours, "hour")} #{time_str(minutes, "minute")} #{ago_or_later(diff)}"
      else
        "#{time_str(hours, "hour")} #{ago_or_later(diff)}"
      end
    end

    def format_minutes(difference_in_seconds, diff)
      minutes = (difference_in_seconds / minute_in_seconds).floor
      remaining_seconds = difference_in_seconds - (minutes * minute_in_seconds)

      if remaining_seconds.positive?
        seconds = remaining_seconds.floor
        "#{time_str(minutes, "minute")} #{time_str(seconds, "second")} #{ago_or_later(diff)}"
      else
        "#{time_str(minutes, "minute")} #{ago_or_later(diff)}"
      end
    end

    def format_seconds(difference_in_seconds, diff)
      seconds = difference_in_seconds.floor
      "#{time_str(seconds, "second")} #{ago_or_later(diff)}"
    end

    def year_in_seconds
      365.25 * 24 * 3600
    end

    def month_in_seconds
      30 * 24 * 3600
    end

    def week_in_seconds
      7 * 24 * 3600
    end

    def day_in_seconds
      24 * 3600
    end

    def hour_in_seconds
      3600
    end

    def minute_in_seconds
      60
    end

    def year_threshold
      year_in_seconds
    end

    def month_threshold
      month_in_seconds
    end

    def week_threshold
      week_in_seconds
    end

    def day_threshold
      day_in_seconds
    end

    def hour_threshold
      hour_in_seconds
    end

    def minute_threshold
      minute_in_seconds
    end

    def ago_or_later(diff_seconds)
      diff_seconds.negative? ? "ago" : "later"
    end

    def time_str(count, singular)
      "#{count} #{count == 1 ? singular : singular.pluralize}"
    end
  end
end
