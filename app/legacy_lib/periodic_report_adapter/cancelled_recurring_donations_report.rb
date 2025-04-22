# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class PeriodicReportAdapter::CancelledRecurringDonationsReport < PeriodicReportAdapter
  def initialize(options)
    @nonprofit_id = options[:nonprofit_id]
    @period = options[:period]
    @user_ids = options[:users].pluck(:id)
  end

  def run
    ExportRecurringDonations.initiate_export(@nonprofit_id, params, @user_ids, :cancelled_recurring_donations_automatic_report)
  end

  private

  def params
    {active: false}.merge(period)
  end

  def period
    method(@period.to_sym).call
  end

  def last_month
    {
      cancelled_at_gt_or_eq: (Time.current - 1.month).beginning_of_month,
      cancelled_at_lt: Time.current.beginning_of_month
    }
  end
end
