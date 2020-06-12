# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class TicketListener < ApplicationListener
    def ticket_create(tickets, charge, user=nil)
        TicketMailer.followup(tickets.map{|i| i.id}, charge && charge.id).deliver_later
        TicketMailer.receipt_admin(tickets.map{|i| i.id}, user && user.id).deliver_later
    end
end