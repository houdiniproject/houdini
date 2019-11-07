class TicketCreateJob < ApplicationJob
  queue_as :default

  def perform(ticket_ids, charge)
    TicketMailer.followup(ticket_ids, charge_id).deliver_now
  end
end
