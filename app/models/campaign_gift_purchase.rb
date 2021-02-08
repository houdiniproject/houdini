# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class CampaignGiftPurchase < ApplicationRecord
  belongs_to :campaign

  has_many :campaign_gifts, class_name: 'ModernCampaignGift'

  validates :amount, presence: true
  validates :campaign, presence: true
  validates :campaign_gifts, length: { minimum: 1 }
  
end
