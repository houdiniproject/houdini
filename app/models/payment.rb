# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# A payment represents the event where a nonprofit receives money from a supporter
# If connected to a charge, this represents money potentially debited to the nonprofit's account
# If connected to an offsite_payment, this is money the nonprofit is recording for convenience.

class Payment < ApplicationRecord

  attr_accessible \
    :towards,
		:gross_amount,
		:refund_total,
		:fee_total,
		:kind,
		:date

	belongs_to :supporter
	belongs_to :nonprofit
	has_one :charge
	has_one :offsite_payment
	has_one :refund
	has_one :dispute
	belongs_to :donation
	has_many :tickets
	has_one :campaign, through: :donation
	has_many :events, through: :tickets
	has_many :payment_payouts
	has_many :charges

end
