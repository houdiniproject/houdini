# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# A Charge represents a potential debit to a nonprofit's account on a credit card donation action.

class Charge < ApplicationRecord

	attr_accessible \
		:amount,
		:fee,
		:stripe_charge_id,
		:status


	has_one :campaign, through: :donation
	has_one :recurring_donation, through: :donation
	has_many :tickets
	has_many :events, through: :tickets
	has_many :refunds
	has_many :disputes
	belongs_to :supporter
	belongs_to :card
	belongs_to :direct_debit_detail
	belongs_to :nonprofit
	belongs_to :donation
	belongs_to :payment

	scope :paid, ->{where(status: ["available", "pending", "disbursed"])}
	scope :not_paid, ->{where(status: [nil, "failed"])}
	scope :available, ->{where(status: "available")}
	scope :pending, ->{where(status: "pending")}
	scope :disbursed, ->{where(status: "disbursed")}

	def paid?
		self.status.in?(%w[available pending disbursed])
	end

end
