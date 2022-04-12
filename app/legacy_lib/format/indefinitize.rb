# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Format
	module Indefinitize
		VOWELS = %w(a e i o u)

		def self.article word
			VOWELS.include?(word[0].downcase) ? 'an' : 'a'
		end

		def self.with_article word
			article(word) + ' ' + word
		end
	end
end
