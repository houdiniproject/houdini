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