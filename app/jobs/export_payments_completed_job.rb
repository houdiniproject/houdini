class ExportPaymentsCompletedJob < EmailJob
  def perform(export)
    ExportMailer.export_payments_completed_notification(export).deliver_now
  end
end
