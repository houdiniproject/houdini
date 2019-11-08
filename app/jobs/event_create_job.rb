class EventCreateJob < ApplicationJob
  queue_as :default

  def perform(event)
    EventCreateCreatorEmailJob.perform_later(event)
  end
end
