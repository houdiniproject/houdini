# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
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
