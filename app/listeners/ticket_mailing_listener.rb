# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class TicketMailingListener < ApplicationListener
  def self.ticket_purchase_created(ticket_purchase)
    tickets_ids = ticket_purchase.ticket_to_legacy_tickets.joins(:ticket).map { |i| i.ticket.id }
    charge = ticket_purchase.ticket_to_legacy_tickets.joins(:ticket).first.charge
    TicketMailer.followup(tickets_ids, charge && charge.id).deliver_later
    TicketMailer.receipt_admin(tickets_ids, nil).deliver_later
  end
end
