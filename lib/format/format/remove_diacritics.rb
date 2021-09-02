# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "i18n"

module Format
	module RemoveDiacritics
		
		def self.from_hash(hash)
      # returns a new hash with any diacritics replaced with a plain character 
      # only from values corresponding to specified keys:
      # {"city" => "São Paulo"} ["city"] will return {"city" => "Sao Paulo"} 
      Hash[hash.map{|k, v| [k, v.present? ? I18n.transliterate(v) : v]}]
		end

	end
end

