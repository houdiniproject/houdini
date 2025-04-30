# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module JobTypes
  class NonprofitFirstTicketPaymentJob < GenericJob
    attr_reader :tickets_id

    def initialize(ticket_ids)
      @ticket_ids = ticket_ids
    end

    def perform
      ticket = Ticket.find(@ticket_ids.first)
      nonprofit = ticket.event&.nonprofit
      if nonprofit && ticket.charge
        np_infos = nonprofit.miscellaneous_np_info || nonprofit.create_miscellaneous_np_info
        np_infos.with_lock("FOR UPDATE") do
          if !np_infos.first_charge_email_sent
            JobQueue.queue(JobTypes::NonprofitFirstChargeEmailJob, nonprofit.id)
            np_infos.first_charge_email_sent = true
            np_infos.save!
          end
        end
      end
    end
  end
end
