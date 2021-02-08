# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class CampaignGiftPurchase < ApplicationRecord
  belongs_to :campaign
  has_many :campaign_gifts, class_name: 'ModernCampaignGift'

  add_builder_expansion :nonprofit, :supporter, :campaign
  add_builder_expansion :trx, 
		json_attrib: :transaction
		
	has_one :transaction_assignment, as: :assignable
	has_one :trx, through: :transaction_assignment
	has_one :supporter, through: :trx
	has_one :nonprofit, through: :supporter

  validates :amount, presence: true
  validates :campaign, presence: true
  validates :campaign_gifts, length: { minimum: 1 }
  
end
