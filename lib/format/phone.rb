# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Format; module Phone
	
	def self.readable(number)
		# Convert to:
		# (505) 263-6320
		# or:
		# 263-6320
		return '' if number.blank?

		stripped = number.gsub(/[-\(\)\.\s]/, '') # remove extra chars and space
		if stripped.length == 10
			return "(#{stripped[0..2]}) #{stripped[3..5]}-#{stripped[6..9]}"
		elsif stripped.length == 7
			return "#{stripped[0..2]}-#{stripped[3..6]}"
		else
			return number
		end
	end

end; end

