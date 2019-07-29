# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module MigrateTicketOrder
    def self.from_ticket_to_orders
        # create ticket order
        tickets_without_payment = Ticket.includes(:supporter).where('payment_id IS NULL')
        tickets_without_payment.each{|i| 
            Qx.transaction do
                to = TicketOrder.create!(supporter: i.supporter)
                i.ticket_order = to
                i.save!

                unless ([i.supporter.address, i.supporter.city, i.supporter.state_code, i.supporter.zip_code, i.supporter.country].all?{|p| p.blank?})
                    to.create_address(supporter: i.supporter,
                        address: i.supporter.address,
                         city: i.supporter.city,
                        state_code: i.supporter.state_code,
                        zip_code: i.supporter.zip_code,
                        country: i.supporter.country
                        )
                end
            end

        }
        
        payments_for_tickets = Ticket.includes(:supporter).where('payment_id IS NOT NULL').select('payment_id').group('payment_id').map{|t| t.payment_id}

        payments_for_tickets.each{|p|
            Qx.transaction do
                tickets = Ticket.where(payment_id: p)

                supporter = tickets.first.supporter
                to = TicketOrder.create!(supporter: supporter)

                tickets.each{|i|
                    i.ticket_order = to
                    i.save!
                }

                if ([supporter.address, supporter.city, supporter.state_code, supporter.zip_code, supporter.country].any?{|prop| prop.present?})
                    addy = to.create_address(supporter: supporter,
                        address: supporter.address,
                         city: supporter.city,
                        state_code: supporter.state_code,
                        zip_code: supporter.zip_code,
                        country: supporter.country
                        )

                    if (!addy.valid?)
                        raise RuntimeError.new (addy)
                    end
                end
            end
        }


    end


end