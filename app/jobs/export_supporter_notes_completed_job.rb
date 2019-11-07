class ExportSupporterNotesCompletedJob < ApplicationJob
  queue_as :default

  def perform(export)
    ExportMailer.export_supporter_notes_completed_notification(export).deliver_now
  end
end
