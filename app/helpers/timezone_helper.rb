module TimezoneHelper
  def time_zone_options_with_iana(selected = nil)
    zones = ActiveSupport::TimeZone.all.map do |zone|
      [zone.to_s, zone.tzinfo.name] # label, IANA value
    end

    options_for_select(zones, selected)
  end
end
