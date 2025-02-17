# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Format
  module Interpolate
    def self.with_hash(str, hash)
      return "" if str.nil?

      str.gsub(/{{.+}}/) { |key| hash[key.gsub(/[{}]/, "")] }
    end
  end
end
