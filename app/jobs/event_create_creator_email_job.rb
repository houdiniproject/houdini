class EventCreateCreatorEmailJob < ApplicationJob
  queue_as :default

  def perform(event)
    EventMailer.creation_followup(event).deliver_now
  end
end
