module JobTypes
  class ImportCompleteNotificationJob < EmailJob
    attr_reader :import_id

    def initialize(import_id)
      @import_id = import_id
    end

    def perform
      ImportMailer.import_completed_notification(@import_id).deliver
    end
  end
end