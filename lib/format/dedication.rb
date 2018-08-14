# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'json'

module Format
  module Dedication

    def self.from_json(json_text)
      begin
        hash = JSON.parse(json_text)
      rescue
        return json_text
      end
      return "Donation made in #{hash['type'] || 'honor'} of #{hash['name']}. Note: #{hash['note']}"
    end
  end
end
