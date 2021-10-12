# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class PeriodicReportAdapter::FailedRecurringDonationsReport < PeriodicReportAdapter
  def initialize(options)
    @nonprofit_id = options[:nonprofit_id]
    @period = options[:period]
    @user_id = options[:user_id]
  end

  def run
    ExportRecurringDonations::initiate_export(@nonprofit_id, params, @user_id, false)
  end

  private

  def params
    { :failed => true, :include_last_failed_charge => true }.merge(period)
  end

  def period
    method(@period.to_sym).call
  end

  def last_month
    {
      :started_at => (Time.current - 1.month).beginning_of_month,
      :end_date => Time.current.beginning_of_month
    }
  end
end
