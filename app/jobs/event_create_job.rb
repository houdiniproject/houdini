class EventCreateJob < ApplicationJob
  queue_as :default

  def perform(event)
    EventCreateCreatorEmailJob(event)
  end
end
