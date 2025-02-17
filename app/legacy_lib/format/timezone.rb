# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Format
  module Timezone
    def self.to_proxy(str)
      dict = {
        "Hawaii" => "Pacific/Honolulu",
        "Alaska" => "America/Juneau",
        "Pacific Time (US & Canada)" => "America/Los_Angeles",
        "Arizona" => "America/Phoenix",
        "Mountain Time (US & Canada)" => "America/Denver",
        "Central Time (US & Canada)" => "America/Chicago",
        "Eastern Time (US & Canada)" => "America/New_York",
        "Indiana (East)" => "America/Indiana/Indianapolis"
      }
      if dict.key?(str)
        dict[str]
      elsif dict.value?(str)
        str
      else
        false
      end
    end
  end
end
