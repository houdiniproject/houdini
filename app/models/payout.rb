# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# Payouts record a credit of the total pending balance on a nonprofit's account
# to their bank account or debit card
#
# These are tied to Stripe transfers

class Payout < ApplicationRecord

	#TODO
	# attr_accessible \
	# 	:scheduled, # bool (whether this was made automatically at the beginning of the month)
	# 	:count, # int (number of donations for this payout)
	# 	:ach_fee, # int (in cents, the total fee for the payout itself)
	# 	:gross_amount, # int (in cents, total amount before fees)
	# 	:fee_total, # int (in cents, total amount of fees)
	# 	:net_amount, # int (in cents, total amount after fees for this payout)
	# 	:email, # str (cache of user email who issued this)
	# 	:user_ip, # str (ip address of the user who made this payout)
	# 	:status, # str ('pending', 'paid', 'canceled', or 'failed')
	# 	:failure_message, # str
	# 	:bank_name, # str: cache of the nonprofit's bank name
	# 	:stripe_transfer_id, # str
	# 	:nonprofit_id, :nonprofit

	belongs_to :nonprofit
	has_one    :bank_account, through: :nonprofit
	has_many   :payment_payouts
	has_many   :payments, through: :payment_payouts

	validates :stripe_transfer_id, presence: true, uniqueness: true
	validates :nonprofit, presence: true
	validates :bank_account, presence: true
	validates :email, presence: true
	validates :net_amount, presence: true, numericality: {greater_than: 0}
	validate  :nonprofit_must_be_vetted, on: :create
	validate  :nonprofit_must_have_identity_verified, on: :create
	validate  :bank_account_must_be_confirmed, on: :create

	scope :pending, -> {where(status: 'pending')}
	scope :paid,    -> {where(status: ['paid', 'succeeded'])}


	def bank_account_must_be_confirmed
		if self.bank_account && self.bank_account.pending_verification
			self.errors.add(:bank_account, 'must be confirmed via email')
		end
	end

	def nonprofit_must_have_identity_verified
		self.errors.add(:nonprofit, "must be verified") unless self.nonprofit && self.nonprofit.verification_status == 'verified'
	end

	def nonprofit_must_be_vetted
		self.errors.add(:nonprofit, "must be vetted") unless self.nonprofit && self.nonprofit.vetted 
	end

end

