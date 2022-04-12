# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Format; module Address
	
	def self.full_address(street, city, state, zip=nil)
		# Albuquerque | NM | Albuquerque NM | 1234 Street Ln, Albuquerque NM
		[[street, city].compact.join(", "), state, zip].compact.join(' ')
	end

	def self.city_and_state(city,state)
	 [city, state].join(', ') if !city.blank? && !state.blank?
	end

	def self.city_or_state(city,state)
		city_and_state(city,state) || city || state
	end

	def self.with_supporter(s)
		return '' if s.nil?
		[[s.address, s.city, s.state_code].reject(&:blank?).join(", "), s.zip_code].reject(&:blank?).join(" ")
	end

end; end

