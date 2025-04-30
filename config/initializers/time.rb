# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
ENV["TZ"] = "UTC"
Time.zone = "UTC"

module Chronic
  def self.time_class
    ::Time.zone
  end
end
