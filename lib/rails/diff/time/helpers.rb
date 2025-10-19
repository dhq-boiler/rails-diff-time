# frozen_string_literal: true

module Rails
  module Diff
    module Time
      module Helpers
        def diff_time(certain_time, element_name = "span", attributes = {})
          render "rails-diff-time/diff_time", locals: {
            diff_time: diff_time_str(certain_time),
            element_name: element_name,
            attributes: attributes
          }
        end

        private

        def diff_time_str(certain_time)
          now = ::Time.now
          diff = certain_time - now
          difference_in_seconds = diff.abs

          # Display "now" if within 5 seconds
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

          if remaining_seconds > 0
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

        # 時間単位の定数メソッド
        def year_in_seconds
          365.25 * 24 * 3600  # うるう年考慮
        end

        def month_in_seconds
          30 * 24 * 3600  # 平均30日
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

        # 閾値メソッド
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
  end
end
