# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class CampaignUpdatedJob < GenericJob
    attr_reader :campaign_id

    def initialize(campaign_id)
      @campaign_id = campaign_id
    end

    def campaign
      Campaign.find(@campaign_id)
    end

    def perform
      campaign.children_campaigns.each do |child|
        JobQueue.queue(JobTypes::ChildCampaignUpdateJob, child.id)
      end
    end
  end
end
