module JobTypes
  class ExportSupportersCompletedJob < EmailJob
    attr_reader :export

    def initialize(export)
      @export = export
    end

    def perform
      ExportMailer.export_supporters_completed_notification(@export).deliver
    end
  end
end
