# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'json'

module Format
  module Dedication
    def self.from_json(json_text)
      begin
        hash = JSON.parse(json_text)
      rescue StandardError
        return json_text
      end
      "Donation made in #{hash['type'] || 'honor'} of #{hash['name']}. Note: #{hash['note']}"
    end
  end
end
