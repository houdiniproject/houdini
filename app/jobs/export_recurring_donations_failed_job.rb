class ExportRecurringDonationsFailedJob < EmailJob
  def perform(export)
    ExportMailer.export_recurring_donations_failed_notification(export).deliver_now
  end
end
