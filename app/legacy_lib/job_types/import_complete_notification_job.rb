# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
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
