# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class CampaignGift < ApplicationRecord

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
