# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class NonprofitAdminSupporterFundraiserJob < EmailJob
    attr_reader :event_or_campaign

    def initialize(event_or_campaign)
      @event_or_campaign = event_or_campaign
    end

    def perform
      NonprofitAdminMailer.supporter_fundraiser(@event_or_campaign).deliver
    end
  end
end
