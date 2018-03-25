module JobTypes
  class CampaignCreationFollowupJob < EmailJob
    attr_reader :campaign

    def initialize(campaign)
      @campaign = campaign
    end

    def perform
      CampaignMailer.creation_followup(@campaign).deliver
    end
  end
end