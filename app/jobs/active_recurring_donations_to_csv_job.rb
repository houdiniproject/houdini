# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class ActiveRecurringDonationsToCsvJob < ExportJob
  queue_as :default

  def perform(opts = {})
    url = ExportRecurringDonations.run_export_for_active_recurring_donations_to_csv(opts[:nonprofit_s3_key], opts[:filename], opts[:export])
    export.update(url: url)
  end
end
