# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

module QueryTicketLevels
  # Given an array of ticket hashes, where each hash has a ticket_level_id and a quantity,
  # calculate the gross amount for all the tickets
  #
  # This could probably be more efficient. I didn't think of a way to calculate it within the query itself.
  # Although I think it's O(n), and n will always be quite small (the number of tickets someone buys)
  def self.gross_amount_from_tickets(tickets, discount_id)
    amounts = TicketLevel.where("id IN (?)", tickets.map { |h| h["ticket_level_id"] }).map { |i| [i.id, i.amount] }.to_h
    total = tickets.map { |t| amounts[t["ticket_level_id"].to_i].to_i * t["quantity"].to_i }.sum

    if discount_id
      perc = EventDiscount.find(discount_id).percent
      total -= (total * (perc / 100.0)).round
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

    unless is_admin
      expr = expr.and_where("coalesce(ticket_levels.admin_only, FALSE) = FALSE")
    end

    expr.execute
  end

  def self.verify_tickets_available(tickets)
    tickets.each do |data|
      next unless data[:quantity] != 0

      tl = TicketLevel.find(data[:ticket_level_id])
      next unless tl.limit && tl.limit > 0

      already_sold = Ticket.where("ticket_level_id = ?", data[:ticket_level_id]).sum("tickets.quantity")
      unless (already_sold + data[:quantity]) <= tl.limit
        raise NotEnoughQuantityError.new(TicketLevel, data[:ticket_level_id], data[:quantity], "Oops! We sold out some of the tickets you wanted before ordering. Please refresh to see what tickets are still available.")
      end
    end
  end
end
