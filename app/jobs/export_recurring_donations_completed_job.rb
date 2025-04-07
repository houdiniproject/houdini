class ExportRecurringDonationsCompletedJob < EmailJob
  def perform(export)
    ExportMailer.export_recurring_donations_completed_notification(@export).deliver_now
  end
end
