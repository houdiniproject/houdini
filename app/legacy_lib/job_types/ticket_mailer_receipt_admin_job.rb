# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class TicketMailerReceiptAdminJob < EmailJob
    attr_reader :ticket_ids

    def initialize(ticket_ids, user_id = nil)
      @ticket_ids = ticket_ids
      @user_id = user_id
    end

    def perform
      TicketMailer.receipt_admin(@ticket_ids, @user_id).deliver
    end
  end
end
