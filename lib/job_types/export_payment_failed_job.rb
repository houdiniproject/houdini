module JobTypes
  class ExportPaymentFailedJob < EmailJob
    attr_reader :export

    def initialize(export)
      @export = export
    end

    def perform
      ExportMailer.export_payments_failed_notification(export).deliver
    end
  end
end