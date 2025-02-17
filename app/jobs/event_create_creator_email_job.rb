class EventCreateCreatorEmailJob < EmailJob
  def perform(event)
    EventMailer.creation_followup(event).deliver_now
  end
end
