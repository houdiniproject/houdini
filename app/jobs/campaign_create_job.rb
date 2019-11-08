class CampaignCreateJob < ApplicationJob
  queue_as :default

  def perform(campaign)
    if campaign.child_campaign?
      CampaignCreationFederatedEmailJob.perform_later(campaign)
    else
      CampaignCreationEmailFollowupJob.perform_later(campaign)
    end

    SupporterFundraiserCreateJob.perform_later(campaign)
  end
end
