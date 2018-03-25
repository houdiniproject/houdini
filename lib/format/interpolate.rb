module Format
  module Interpolate
    def self.with_hash(str, hash)
      return '' if str.nil?
      str.gsub(/{{.+}}/){|key| hash[key.gsub(/[{}]/,'')]}
    end
  end
end
