# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class MiscCampaignInfo < ApplicationRecord
  belongs_to :campaign

  validates :fee_coverage_option_config, inclusion: {in: ["auto", "manual", "none", nil]}

  attr_accessible :manual_cover_fees, :paused
end
