# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class AdminNoticeJob < EmailJob
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def perform
      GenericMailer.admin_notice(@options).deliver
    end
  end
end
