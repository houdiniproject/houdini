# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class TicketMailer < BaseMailer
  helper :application

  # Pass in ticket_ids, event_id, and supporter
  def followup(ticket_ids, charge_id = nil)
    @charge = charge_id ? Charge.find(charge_id) : nil
    @tickets = Ticket.where("id IN(?)", ticket_ids)
    @event = @tickets.last.event
    @supporter = @tickets.last.supporter
    @nonprofit = @supporter.nonprofit
    from = Format::Name.email_from_np(@nonprofit.name)
    reply_to = @nonprofit.email.presence || @nonprofit.users.first.email
    mail(from: from, to: @supporter.email, reply_to: reply_to, subject: "Your tickets#{@charge ? " and receipt " : " "}for: #{@event.name}")
  end

  def receipt_admin(ticket_ids, user_id = nil)
    @tickets = Ticket.where("id IN (?)", ticket_ids)
    @charge = @tickets.last.charge
    @supporter = @tickets.last.supporter
    @event = @tickets.last.event
    @nonprofit = @event.nonprofit
    recipients = QueryUsers.nonprofit_user_emails(@nonprofit.id, "notify_events")
    if user_id
      em = User.find(user_id).email
      return unless recipients.include?(em)

      recipients = [em]
    end
    mail(to: recipients, subject: "Ticket redeemed for #{@event.name} - #{@supporter.name}")
  end
end
