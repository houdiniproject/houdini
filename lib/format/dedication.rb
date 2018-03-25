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
