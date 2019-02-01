# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class CampaignGiftOption < ApplicationRecord

	attr_accessible \
		:amount_one_time, #int (cents)
		:amount_recurring, #int (cents)
		:amount_dollars, #str, gets converted to amount
		:description, # text
		:name, # str
		:campaign, #assocation
		:quantity, #int (optional)
		:to_ship, #boolean 
		:order, #int (optional) 
		:hide_contributions #boolean (optional) 

	belongs_to :campaign
	has_many :campaign_gifts
	has_many :donations, through: :campaign_gifts

	validates :name, presence: true
	validates :campaign, presence: true
	validates :amount_one_time,  presence: true, numericality: { only_integer: true }, unless: :amount_recurring
	validates :amount_recurring, presence: true, numericality: { only_integer: true }, unless: :amount_one_time

	def total_gifts
		return self.campaign_gifts.count
	end

	def as_json(options={})
		h = super(options)
		h[:total_gifts] = self.total_gifts
		h
	end

end
