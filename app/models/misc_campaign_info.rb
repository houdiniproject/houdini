class MiscCampaignInfo < ActiveRecord::Base
  belongs_to :campaign
  attr_accessible :manual_cover_fees
end
