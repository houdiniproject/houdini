class CampaignGift < ActiveRecord::Base

	attr_accessible \
		:donation_id,
		:donation,
		:campaign_gift_option,
		:campaign_gift_option_id

	belongs_to :donation
	belongs_to :campaign_gift_option

	validates :donation, presence: true
	validates :campaign_gift_option, presence: true

end
