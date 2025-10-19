# frozen_string_literal: true

module Helpers
  def diff_time(certain_time, element_name = "span", attributes = {})
    render "diff_time", locals: {
      diff_time: diff_time_str(certain_time),
      element_name: element_name,
      attributes: attributes
    }
  end

  private

  def diff_time_str(certain_time)
    now = Time.now
    diff = certain_time - now
    difference_in_seconds = diff.abs

    # 現在時刻とcertain_timeの間にうるう年が含まれて入れば、うるう年が含まれる回数だけ秒数を追加
    leap_years_count = (certain_time.year..now.year).count do |year|
      Date.gregorian_leap?(year)
    end
    difference_in_seconds += leap_years_count * 86_400 if leap_years_count.positive?

    # うるう年でない年の秒数も追加
    difference_in_seconds += (now.year - certain_time.year - leap_years_count) * 31_536_000

    # 中略

    # 分、時間、日、週、月、年に変換
    seconds = difference_in_seconds.floor
    minutes = (difference_in_seconds / 60).floor
    hours = (difference_in_seconds / 3600).floor
    days = (difference_in_seconds / 86_400).floor
    weeks = (difference_in_seconds / 604_800).floor
    months = (difference_in_seconds / 2_592_000).floor
    years = (difference_in_seconds / 31_536_000).floor

    if years.positive? && months.positive? && days.positive?
      "#{pluralize(years,
                   "year")} #{pluralize(months - (years * 12),
                                        "month")} #{pluralize(days - (years * 365) - (months * 30),
                                                              "day")} #{ago_or_later diff}"
    elsif years.positive? && months.positive?
      "#{pluralize(years, "year")} #{pluralize(months - (years * 12), "month")} #{ago_or_later diff}"
    elsif years.positive?
      "#{pluralize(years, "year")} #{ago_or_later diff}"
    elsif months.positive? && days.positive?
      "#{pluralize(months, "month")} #{pluralize(days - (months * 30), "day")} #{ago_or_later diff}"
    elsif weeks.positive?
      "#{pluralize(weeks, "week")} #{ago_or_later diff}"
    elsif days.positive?
      "#{pluralize(days, "day")} #{ago_or_later diff}"
    elsif hours.positive? && minutes.positive?
      "#{pluralize(hours, "hour")} #{pluralize(minutes - (hours * 60), "minute")} #{ago_or_later diff}"
    elsif hours.positive?
      "#{pluralize(hours, "hour")} #{ago_or_later diff}"
    elsif minutes.positive? && seconds.positive?
      "#{pluralize(minutes, "minute")} #{pluralize(seconds - (minutes * 60), "seconds")} #{ago_or_later diff}"
    else
      "#{pluralize(seconds, "seconds")} #{ago_or_later diff}"
    end
  end

  def ago_or_later(diff_time)
    diff_time < Time.now ? "ago" : "later"
  end
end
