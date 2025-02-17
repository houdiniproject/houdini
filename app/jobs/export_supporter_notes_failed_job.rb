class ExportSupporterNotesFailedJob < EmailJob
  def perform(export)
    ExportMailer.export_supporter_notes_failed_notification(export).deliver_now
  end
end
