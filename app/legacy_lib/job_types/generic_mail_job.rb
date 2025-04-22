# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class GenericMailJob < EmailJob
    attr_reader :from_email, :from_name, :message, :subject, :to_email, :to_name

    def initialize(from_email, from_name, message, subject, to_email, to_name)
      @from_email = from_email
      @from_name = from_name
      @message = message
      @subject = subject
      @to_email = to_email
      @to_name = to_name
    end

    def perform
      GenericMailer.generic_mail(@from_email, @from_name, @message, @subject, @to_email, @to_name).deliver
    end
  end
end
