class CampaignCreationFederatedEmailJob < EmailJob
  def perform(campaign)
    CampaignMailer.federated_creation_followup(campaign).deliver_now
  end
end
