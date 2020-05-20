class RecurringDonationsExportCreateJob < ApplicationJob
  queue_as :default

  def perform(*args)
    ExportRecurringDonations.run_export(*args)
  end
end
