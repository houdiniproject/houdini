# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'hashie'

module QueryTicketLevels

  # Given an array of ticket hashes, where each hash has a ticket_level_id and a quantity,
  # calculate the gross amount for all the tickets
  #
  # This could probably be more efficient. I didn't think of a way to calculate it within the query itself.
  # Although I think it's O(n), and n will always be quite small (the number of tickets someone buys)
  def self.gross_amount_from_tickets_with_possible_fee_coverage(tickets, discount_id, fee_covered, nonprofit_id, stripe_customer_id)
    total = gross_amount_from_tickets(tickets, discount_id)

    if fee_covered
      stripe_cust = Stripe::Customer.retrieve({id: stripe_customer_id, expand: ['default_source']}, {stripe_version: "2019-09-09"})
      fees = CalculateFees.reverse_for_single_amount(total, 
        platform_fee: BillingPlans.get_percentage_fee(nonprofit_id),
        source: stripe_cust.default_source, 
        switchover_date: FEE_SWITCHOVER_TIME);
      total = total + fees
    end

    return total
  end

  def self.gross_amount_from_tickets(tickets, discount_id)
    amounts = TicketLevel.where('id IN (?)', tickets.map{|h| h['ticket_level_id']}).map{|i| [i.id, i.amount]}.to_h
    total = tickets.map{|t| amounts[t['ticket_level_id'].to_i].to_i * t['quantity'].to_i}.sum

    if discount_id
      perc = EventDiscount.find(discount_id).percent
      total = total - (total * (perc / 100.0)).round
    end
    total
  end
  

  def self.with_event_id(event_id, is_admin)
    expr = Qx.select("ticket_levels.*", "SUM(tickets.quantity) AS quantity")
      .from(:ticket_levels)
      .left_join([:tickets, "ticket_levels.id=tickets.ticket_level_id"])
      .group_by("ticket_levels.id")
      .where("ticket_levels.event_id = $id", id: event_id)
      .order_by("ticket_levels.order ASC, coalesce(ticket_levels.amount, 'Infinity'::float) ASC, LOWER(ticket_levels.name) ASC") # This puts free ticket levels at the bottom

    if !is_admin
      expr = expr.and_where("coalesce(ticket_levels.admin_only, FALSE) = FALSE")
    end

    return expr.execute
  end

  def self.verify_tickets_available(tickets)
    tickets.each{|data|
      if (data[:quantity] != 0)
        tl = TicketLevel.find(data[:ticket_level_id])
        if tl.limit && tl.limit > 0
          already_sold = Ticket.where('ticket_level_id = ?', data[:ticket_level_id]).sum('tickets.quantity')
          unless (already_sold + data[:quantity]) <= tl.limit
            raise NotEnoughQuantityError.new(TicketLevel, data[:ticket_level_id], data[:quantity], "Oops! We sold out some of the tickets you wanted before ordering. Please refresh to see what tickets are still available.")
          end
        end
      end
    }
  end

end
