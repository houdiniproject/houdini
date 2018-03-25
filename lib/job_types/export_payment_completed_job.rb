module JobTypes
  class ExportPaymentCompletedJob < EmailJob
    attr_reader :export

    def initialize(export)
      @export = export
    end

    def perform
      ExportMailer.export_payments_completed_notification(export).deliver
    end
  end
end