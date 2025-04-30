# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# For tracking and calculating timespans/time intervals
# Relies on activesupport

Timespan = Struct.new(:interval, :time_unit) do
  self::Units = ["week", "day", "month", "year"]
  self::TimeUnits = {
    "1_week" => 1.week.ago,
    "2_weeks" => 2.weeks.ago,
    "1_month" => 1.month.ago,
    "3_months" => 3.months.ago,
    "6_months" => 6.months.ago,
    "1_year" => 1.year.ago,
    "2_years" => 2.years.ago
  }
end
