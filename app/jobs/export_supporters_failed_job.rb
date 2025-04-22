class ExportSupportersFailedJob < EmailJob
  def perform(export)
    ExportMailer.export_supporters_failed_notification(export).deliver_now
  end
end
