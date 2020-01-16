# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'stripe'
require 'calculate/calculate_fees'

module StripeUtils

	def self.create_transfer(net_amount, stripe_account_id, currency)
		Stripe::Payout.create({
			amount: net_amount,
			currency: currency || Settings.intntl.currencies[0]
		}, {
			stripe_account: stripe_account_id
		})
	end


	def self.create_refund(stripe_charge, amount, reason)
		stripe_charge.refunds.create({
			amount: amount,
			refund_application_fee: true,
			reverse_transfer: true,
			reason: reason
		})
	end
end
