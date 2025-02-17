# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
ENV["TZ"] = "UTC"
Time.zone = "UTC"

module Chronic
  def self.time_class
    ::Time.zone
  end
end
