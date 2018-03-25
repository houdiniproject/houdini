module JobTypes
  class ExportRecurringDonationsFailedJob < EmailJob
    attr_reader :export

    def initialize(export)
      @export = export
    end

    def perform
      ExportMailer.export_recurring_donations_failed_notification(@export).deliver
    end
  end
end