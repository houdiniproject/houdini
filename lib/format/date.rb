# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'chronic'

module Format; module Date

	ISORegex = /\d\d\d\d-\d\d-\d\d/

  def self.parse(str)
    Chronic.parse(str)
  end

	def self.from(str)
		return DateTime.strptime(str, "%m/%d/%Y")
	end

	def self.to_readable(date)
		date.strftime("%A, %B #{date.day.ordinalize}")
	end

	def self.full(date, timezone=nil)
    return '' if date.nil?
    date = Chronic.parse(date) if date.is_a?(String)
		date = date.in_time_zone(timezone) if timezone
		date.strftime("%m/%-d/%Y %l:%M%P")
	end

  def self.full_range(date1, date2, timezone=nil)
    return full(date1, timezone) if date2.nil?
    return full(date2, timezone) if date1.nil?
    if simple(date1) == simple(date2)
      return full(date1, timezone) + ' - ' + time(date2, timezone)
    else
      return full(date1, timezone) + ' - ' + full(date2, timezone)
    end
  end

	def self.simple(date, timezone=nil)
    return '' if date.nil?
		date = Chronic.parse(date) if date.is_a?(String)
		date = date.in_time_zone(timezone) if timezone
		date.strftime("%m/%d/%Y")
	end

  def self.time(datetime, timezone=nil)
    return '' if datetime.nil?
		datetime = Chronic.parse(datetime) if datetime.is_a?(String)
    datetime = datetime.in_time_zone(timezone) if timezone
    datetime.strftime("%l:%M%P")
  end

	def self.us_timezones
          #zones=ActiveSupport::TimeZone.us_zones
          zones=ActiveSupport::TimeZone.all
		names = zones.map(&:name)
		vals = zones.map{|t| t.tzinfo.name}
		return names.zip(vals).sort_by{|name, val| name}
	end

  def self.parse_partial_str(str)
    return nil if str.nil?
    Time.new(*str.match(/(\d\d\d\d)-?(\d\d)?-?(\d\d)?/).to_a[1..-1].compact.map(&:to_i))
  end

end; end
