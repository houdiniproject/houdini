# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class PeriodicReportAdapter::FailedRecurringDonationsReport < PeriodicReportAdapter
  def initialize(options)
    @nonprofit_id = options[:nonprofit_id]
    @period = options[:period]
    @user_ids = options[:users].pluck(:id)
  end

  def run
    ExportRecurringDonations.initiate_export(@nonprofit_id, params, @user_ids, :failed_recurring_donations_automatic_report)
  end

  private

  def params
    {failed: true, include_last_failed_charge: true}.merge(period)
  end

  def period
    method(@period.to_sym).call
  end

  def last_month
    {
      from_date: 1.month.ago.beginning_of_month,
      before_date: Time.current.beginning_of_month
    }
  end
end
