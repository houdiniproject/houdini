# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class PostgresqlDateFormatValidator < ActiveModel::Validator
  # based on https://www.postgresql.org/docs/current/functions-formatting.html
  # must receive a { options: { attribute_name: <date attribute name> } } to do the validation
  def validate(record)
    date_format = record[options[:attribute_name]]
    unless date_format.nil? || valid_date_format?(date_format)
      record.errors.add(:date_format, "invalid date format")
    end
  end

  private

  def valid_date_format?(date_format)
    ALLOWED_SEPARATORS.each do |separator|
      date_format = date_format.split(separator).flatten
    end
    date_format.each do |date_pattern_element|
      return false unless ALLOWED_POSTGRES_PATTERNS.include?(date_pattern_element)
    end
    true
  end

  ALLOWED_SEPARATORS = ["/", "-", ".", ":"].freeze

  ALLOWED_POSTGRES_PATTERNS = [
    "HH", "HH12", "HH24", "MI", "SS", "MS", "US", "FF1", "FF2", "FF3", "FF4", "FF5", "FF6",
    "SSSS", "SSSSS", "AM", "am", "PM", "pm", "A.M.", "a.m.", "P.M.", "p.m.", "Y", "YYYY", "YYY",
    "YY", "Y", "IYYY", "IYY", "IY", "I", "BC", "bc", "AD", "ad", "B.C.", "b.c.", "A.D.", "a.d.",
    "MONTH", "Month", "month", "MON", "Mon", "mon", "MM", "DAY", "Day", "day", "DY", "Dy", "dy",
    "DDD", "IDDD", "DD", "D", "ID", "W", "WW", "IW", "CC", "J", "Q", "RM", "rm", "TZ", "tz",
    "TZH", "TZM", "OF"
  ].freeze
end
