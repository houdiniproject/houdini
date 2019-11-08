class CampaignCreateJob < ApplicationJob
  queue_as :default

  def perform(campaign)
    if campaign.child_campaign?
      CampaignMailer.federated_creation_followup(campaign).deliver_later
    else
      CampaignMailer.creation_followup(campaign).deliver_later
    end

    SupporterFundraiserCreateJob.perform_later(campaign)
  end
end
