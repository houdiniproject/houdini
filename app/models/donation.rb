# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Donation < ActiveRecord::Base

	attr_accessible \
		:date, # datetime (when this donation was made)
		:amount, # int (in cents)
		:recurring, # bool
		:anonymous, # bool
		:email, # str (cached email of the donor)
		:designation, # text
		:dedication, # text
		:comment, # text
		:origin_url, # text
		:nonprofit_id, :nonprofit,
		:card_id, :card, # Card with which any charges were made
		:supporter_id, :supporter,
		:profile_id, :profile,
		:campaign_id, :campaign,
		:payment_id, :payment,
		:event_id, :event,
		:direct_debit_detail_id, :direct_debit_detail,
    :payment_provider

	validates :amount, presence: true, numericality: { only_integer: true }
	validates :supporter, presence: true
	validates :nonprofit, presence: true
	validates_associated :charges
  validates :payment_provider, inclusion: { in: ["credit_card", "sepa"]}, allow_blank: true

	has_many :charges
	has_many :campaign_gifts, dependent: :destroy
	has_many :campaign_gift_options, through: :campaign_gifts
	has_many :activities, as: :attachment, dependent: :destroy
	has_many :payments
	has_one :recurring_donation
	has_one :payment
	has_one :offsite_payment
	has_one :tracking
	belongs_to :supporter
	belongs_to :card
	belongs_to :direct_debit_detail
	belongs_to :profile
	belongs_to :nonprofit
	belongs_to :campaign
	belongs_to :event

	scope :anonymous, -> {where(anonymous: true)}
end
