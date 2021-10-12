# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class CampaignGift < ApplicationRecord
  # :donation_id,
  # :donation,
  # :campaign_gift_option,
  # :campaign_gift_option_id

  belongs_to :donation
  belongs_to :campaign_gift_option
  has_one :modern_campaign_gift

  validates :donation, presence: true
  validates :campaign_gift_option, presence: true
end
