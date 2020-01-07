class TicketListener
    def ticket_create(tickets, charge, user=nil)
        TicketMailer.followup(tickets.map{|i| i.id}, charge && charge.id).deliver_later
        TicketMailer.receipt_admin(tickets.map{|i| i.id}, user && user.id).deliver_later
    end
end