module JobTypes
  class ExportSupportersFailedJob < EmailJob
    attr_reader :export

    def initialize(export)
      @export = export
    end

    def perform
      ExportMailer.export_supporters_failed_notification(@export).deliver
    end
  end
end
