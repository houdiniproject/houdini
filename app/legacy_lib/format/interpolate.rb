# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Format
  module Interpolate
    def self.with_hash(str, hash)
      return '' if str.nil?
      str.gsub(/{{.+}}/){|key| hash[key.gsub(/[{}]/,'')]}
    end
  end
end
