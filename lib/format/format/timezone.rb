# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Format
  module Timezone
    def self.to_proxy(str)
     dict = {
       "Hawaii"                      => 'Pacific/Honolulu', 
       "Alaska"                      => 'America/Juneau',
       "Pacific Time (US & Canada)"  => 'America/Los_Angeles',
       "Arizona"                     => 'America/Phoenix',
       "Mountain Time (US & Canada)" => 'America/Denver',
       "Central Time (US & Canada)"  => 'America/Chicago',
       "Eastern Time (US & Canada)"  => 'America/New_York',
       "Indiana (East)"              => 'America/Indiana/Indianapolis'
      }
      if dict.has_key?(str)
        return dict[str]
      elsif dict.has_value?(str)
        return str
      else
        return false 
      end
    end
  end
end

