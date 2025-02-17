# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class CampaignListener < ApplicationListener
  def self.campaign_create(campaign)
    if campaign.child_campaign?
      CampaignCreationFederatedEmailJob.perform_later(campaign)
    else
      CampaignCreationEmailFollowupJob.perform_later(campaign)
    end

    SupporterFundraiserCreateJob.perform_later(campaign)
  end
end
