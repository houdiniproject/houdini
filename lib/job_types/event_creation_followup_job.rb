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