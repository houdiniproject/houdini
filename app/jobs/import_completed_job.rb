class ImportCompletedJob < EmailJob
  def perform(import)
    ImportMailer.import_completed_notification(import.id).deliver_now
  end
end
