# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
# For tracking and calculating timespans/time intervals
# Relies on activesupport
require "active_support/time"

Timespan = Struct.new(:interval, :time_unit) do
  self::Units = %w[week day month year].freeze
  self::TimeUnits = {
    "1_week" => 1.week.ago,
    "2_weeks" => 2.weeks.ago,
    "1_month" => 1.month.ago,
    "3_months" => 3.months.ago,
    "6_months" => 6.months.ago,
    "1_year" => 1.year.ago,
    "2_years" => 2.years.ago
  }.freeze

  # Test if end_date is past start_date by timespan
  # eg: later_than_by?(Jun 13th, Jul 14th, 1.month) -> true
  # Special case:
  # later_than_by?(Jan 31st, Feb 28th, 1.month) -> true
  def self.later_than_by?(start_date, end_date, timespan)
    (start_date + timespan) <= end_date
  end

  # Given an Integer (frequency) and a String (time unit),
  # return the timespan object (ie. number of seconds) constituting the timespan
  # timespan(1, 'minute') -> 60
  # timespan(1, 'month') -> 2592000
  def self.create(interval, time_unit)
    raise(ArgumentError, "time_unit must be one of: #{self::Units}") unless self::Units.include?(time_unit)

    interval.send(time_unit.to_sym)
  end

  def self.in_future?(datetime)
    datetime > Time.current
  end

  def self.date_now_or_in_future?(date)
    date >= Date.today
  end

  def self.in_past?(date)
    date < Time.current
  end
end
