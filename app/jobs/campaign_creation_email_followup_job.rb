class CampaignCreationEmailFollowupJob < ApplicationJob
  queue_as :default

  def perform(campaign)
    CampaignMailer.creation_followup(campaign).deliver_now
  end
end
