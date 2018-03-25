module FetchNonprofitEmail

	def self.with_charge charge
		nonprofit = charge.nonprofit
		nonprofit.email.blank? ? Settings.mailer.email : nonprofit.email
	end

	def self.with_donation donation
		nonprofit = donation.nonprofit
		nonprofit.email.blank? ? Settings.mailer.email : nonprofit.email
	end
end
