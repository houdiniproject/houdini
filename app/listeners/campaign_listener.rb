class CampaignListener < ApplicationListener
    def campaign_create(campaign)
      if campaign.child_campaign?
        CampaignCreationFederatedEmailJob.perform_later(campaign)
      else
        CampaignCreationEmailFollowupJob.perform_later(campaign)
      end
  
      SupporterFundraiserCreateJob.perform_later(campaign)
    end
end
