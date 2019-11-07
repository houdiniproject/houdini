class TicketCreateJob < ApplicationJob
  queue_as :default

  def perform(ticket_ids, charge, user=nil)
    TicketMailer.followup(ticket_ids, charge_id).deliver_later
    TicketMailer.receipt_admin(ticket_ids, user.id).deliver_later
  end
end
