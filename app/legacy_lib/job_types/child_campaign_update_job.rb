# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class ChildCampaignUpdateJob < GenericJob
    attr_reader :child_campaign_id

    def initialize(child_campaign_id)
      @child_campaign_id = child_campaign_id
    end

    def child_campaign
      Campaign.find(child_campaign_id)
    end

    def perform
      child_campaign.update_from_parent!
    end
  end
end
