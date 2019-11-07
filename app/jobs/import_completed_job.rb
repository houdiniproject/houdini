class ImportCompletedJob < ApplicationJob
  queue_as :default

  def perform(import)
    ImportMailer.import_completed_notification(import.id).deliver_now
  end
end
