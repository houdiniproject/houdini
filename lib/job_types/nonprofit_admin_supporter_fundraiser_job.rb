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