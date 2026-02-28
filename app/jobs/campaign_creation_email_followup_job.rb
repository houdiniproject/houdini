class CampaignCreationEmailFollowupJob < EmailJob
  def perform(campaign)
    CampaignMailer.creation_followup(campaign).deliver_now
  end
end
