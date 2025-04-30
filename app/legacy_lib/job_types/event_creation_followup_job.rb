# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class EventCreationFollowupJob < EmailJob
    attr_reader :event

    def initialize(event)
      @event = event
    end

    def perform
      EventMailer.creation_followup(@event).deliver
    end
  end
end
