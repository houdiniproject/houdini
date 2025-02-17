class ExportSupportersCompletedJob < EmailJob
  def perform(export)
    ExportMailer.export_supporters_completed_notification(export).deliver_now
  end
end
