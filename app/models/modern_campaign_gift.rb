# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class ModernCampaignGift < ApplicationRecord
	include Model::Houidable
  include Model::Jbuilder
  include Model::Eventable
	setup_houid :cgift
	
	belongs_to :campaign_gift_purchase
	belongs_to :legacy_campaign_gift,  class_name: 'CampaignGift', foreign_key: :campaign_gift_id, inverse_of: :modern_campaign_gift

	validates :amount, presence: true
	validates :legacy_campaign_gift, presence: true
	validates :campaign_gift_purchase, presence: true
	
end
