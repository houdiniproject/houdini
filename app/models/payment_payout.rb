# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# charge_payouts are a join table between charges and payouts
#
# The reason we need a join table between charges and payouts:
# A single charge can have multiple charge_payouts. For example, if we make a
# payout that later fails, we want to keep a record of all the charges for that
# failed payout. When the nonprofit later makes a second payout that succeeds,
# all those charges will now have to charge_payouts: one of the failed payout,
# and one for the succeeded payout
#
# It's also nice to keep a historical records of fees for individual donations
# since our fees will continue to change as our transaction volume increases

class PaymentPayout < ApplicationRecord

	#TODO
	# attr_accessible \
	# 	:payment_id, :payment,
	# 	:charge_id, :charge, # deprecated
	# 	:payout_id, :payout,
	# 	:total_fees # int (cents)

	belongs_to :charge # deprecated
	belongs_to :payment
	belongs_to :payout

	validates :payment, presence: true
	validates :payout, presence: true
end

