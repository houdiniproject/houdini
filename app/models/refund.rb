# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Refund < ApplicationRecord

	Reasons = [:duplicate, :fraudulent, :requested_by_customer]

	attr_accessible \
		:amount, # int
		:comment, # text
		:reason, # str ('duplicate', 'fraudulent', or 'requested_by_customer')
		:stripe_refund_id,
		:disbursed, # boolean (whether this refund has been counted in a payout)
		:failure_message, # str (accessor for storing the Stripe error message)
		:user_id, :user, # user who made this refund
		:payment_id, :payment, # negative payment that records this refund
		:charge_id, :charge

	attr_accessor :failure_message

	belongs_to :charge
	belongs_to :payment
	has_one :subtransaction_payment, through: :payment
	has_one :misc_refund_info
	has_one :nonprofit, through: :charge
	has_one :supporter, through: :charge

	scope :not_disbursed, ->{where(disbursed: [nil, false])}
	scope :disbursed, ->{where(disbursed: [true])}

	has_many  :manual_balance_adjustments, as: :entity


	def original_payment
		charge&.payment
	end

	def from_donation?
		!!original_payment&.donation
	end

end

