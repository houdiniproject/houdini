# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module QueryTickets
  def self.attendees_expr(event_id, query)
    expr = Qexpr.new
      .from("tickets")
      .where("coalesce(tickets.deleted, FALSE) = FALSE")
      .left_outer_join("event_discounts", "event_discounts.id=tickets.event_discount_id")
      .left_outer_join(
        Qexpr.new.select("*")
        .from(:supporters).group_by("id").as("supporters"),
        "tickets.supporter_id=supporters.id"
      )
      .left_outer_join("charges", "charges.id=tickets.charge_id")
      .left_outer_join(
        Qexpr.new.select("charge_id", "SUM(coalesce(amount, 0)) AS amount")
        .from(:refunds)
        .group_by(:charge_id)
        .as(:refunds),
        "refunds.charge_id=charges.id"
      )
      .left_outer_join(
        Qexpr.new.select("id", "name", "amount")
        .from(:ticket_levels).group_by("id").as("ticket_levels"),
        "tickets.ticket_level_id=ticket_levels.id"
      )
      .left_outer_join(
        Qexpr.new.select("token", "tokenizable_id").from(:source_tokens).group_by("token", "tokenizable_id").as("source_tokens"),
        "tickets.source_token_id=source_tokens.token"
      )
      .left_outer_join(
        # TODO: this does not support anything other than cards!
        Qexpr.new.select("id", "name").from(:cards).group_by("id", "name").as("cards"),
        "source_tokens.tokenizable_id = cards.id"
      )
      .left_outer_join(
        Qexpr.new.select("supporter_id", "MAX(event_id) AS event_id", "SUM(amount) AS total_amount")
        .from(:donations).where("event_id=$id", id: event_id).group_by("supporter_id").as(:donations),
        "donations.supporter_id=supporters.id AND donations.event_id=$id", id: event_id
      )
      .where("tickets.event_id=$id", id: event_id)
      .order_by("tickets.bid_id DESC")
    if query[:search].present?
      query[:search] = "%#{query[:search].downcase.split(" ").join("%")}%"
      expr = expr.where(%(
            lower(supporters.name)    LIKE $search
         OR lower(supporters.email)   LIKE $search
         OR lower(ticket_levels.name) LIKE $search
       ), search: "%" + query[:search] + "%")
    end
    if %w[asc desc].include? query[:sort_attendee]
      expr = expr.order_by("lower(supporters.name) #{query[:sort_attendee]} NULLS LAST")
    end
    if %w[asc desc].include? query[:sort_id]
      expr = expr.order_by("tickets.bid_id #{query[:sort_id]}")
    end
    if %w[asc desc].include? query[:sort_note]
      expr = expr.order_by("lower(tickets.note) #{query[:sort_note]} NULLS LAST")
    end
    if %w[asc desc].include? query[:sort_ticket_level]
      expr = expr.order_by("lower(ticket_levels.name) #{query[:sort_ticket_level]} NULLS LAST")
    end
    if %w[asc desc].include? query[:sort_donation]
      expr = expr.order_by("total_donations #{query[:sort_donation]} NULLS LAST")
    end
    expr
  end

  def self.attendees_list(event_id, query)
    limit = 30
    offset = Qexpr.page_offset(limit, query[:page])

    data = Psql.execute(
      attendees_expr(event_id, query)
      .limit(limit).offset(offset)
      .select(*attendees_list_selection)
    )

    total_count = Psql.execute(
      Qexpr.new.select("COUNT(ts)")
        .from(attendees_expr(event_id, query)
        .remove(:order_by).select("tickets.id"), "ts")
    ).first["count"]

    # TODO: this worries me. Seems like a recipe for slow returns... perhaps some caching of the tokens every so often?
    data.each do |i|
      unless i["source_token_id"] && QuerySourceToken.source_token_unexpired?(SourceToken.find(i["source_token_id"]))
        i["source_token_id"] = nil
      end
    end

    {
      data: data,
      total_count: total_count,
      remaining: Qexpr.remaining_count(total_count, limit, query[:page])
    }
  end

  def self.for_export(event_id, query)
    Psql.execute_vectors(
      attendees_expr(event_id, query)
      .select([
        "tickets.bid_id AS id",
        "ticket_levels.name AS ticket_level",
        "MONEY((coalesce(charges.amount, 0) - coalesce(refunds.amount, 0)) / 100.0) AS ticket_cost",
        "MONEY(coalesce(donations.total_amount, 0) / 100.0) AS total_donations",
        "tickets.quantity",
        'tickets.checked_in AS "Checked In?"',
        "tickets.note",
        "CASE WHEN event_discounts.id IS NULL THEN 'None' ELSE concat(event_discounts.name, ' (', event_discounts.percent, '%)') END AS \"Discount\"",
        "CASE WHEN tickets.card_id IS NULL OR tickets.card_id = 0 THEN '' ELSE 'YES' END AS \"Card Saved?\""
      ].concat(QuerySupporters.supporter_export_selections))
    )
  end

  def self.attendees_list_selection
    ["tickets.id",
      "tickets.bid_id",
      "tickets.checked_in",
      "tickets.quantity",
      "tickets.note",
      "tickets.source_token_id",
      "ticket_levels.name AS ticket_level_name",
      "(coalesce(charges.amount, 0) - coalesce(refunds.amount, 0)) AS total_paid",
      "ticket_levels.id AS ticket_level_id",
      "ticket_levels.amount AS ticket_level_amount",
      "event_discounts.percent AS discount_percent",
      "supporters.id AS supporter_id",
      "supporters.name AS name",
      "supporters.email AS email",
      "coalesce(donations.total_amount, 0) AS total_donations",
      "source_tokens.token AS token",
      "cards.name AS card_name"]
  end

  def self.for_event_activities(event_id)
    selects = ["
      CASE
        WHEN supporters.anonymous='t'
          OR supporters.name=''
          OR supporters.name IS NULL
        THEN 'A supporter'
        ELSE supporters.name
      END AS supporter_name",
      "tickets.quantity", "tickets.created_at"]
    Qx.select(selects.join(","))
      .from(:tickets)
      .left_join(:supporters, "tickets.supporter_id=supporters.id")
      .where("tickets.event_id=$id", id: event_id)
      .order_by("tickets.created_at desc")
      .limit(15)
      .execute
  end
end
