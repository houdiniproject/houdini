# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class PeriodicReportAdapter
  extend ActiveSupport::Autoload

  autoload :CancelledRecurringDonationsReport
  autoload :FailedRecurringDonationsReport
  autoload :ActiveRecurringDonationsToCsvReport
  autoload :StartedRecurringDonationsToCsvReport

  REPORT = "Report"
  private_constant :REPORT

  class << self
    def build(options)
      lookup(options[:report_type]).new(**options)
    end

    def lookup(type)
      const_get(type.to_s.camelize << REPORT)
    end
  end
end
