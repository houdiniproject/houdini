# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "json"

module Format
  module Dedication
    def self.from_json(json_text)
      begin
        hash = JSON.parse(json_text)
      rescue
        return json_text
      end
      "Donation made in #{hash["type"] || "honor"} of #{hash["name"]}. Note: #{hash["note"]}"
    end
  end
end
