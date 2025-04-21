class ExportPaymentsFailedJob < EmailJob
  def perform(export)
    ExportMailer.export_payments_failed_notification(export).deliver_now
  end
end
