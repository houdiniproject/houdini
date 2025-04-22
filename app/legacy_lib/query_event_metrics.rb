# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module QueryEventMetrics
  def self.expression(additional_selects = [])
    selects = [
      "coalesce(tickets.total, 0) AS total_attendees",
      "coalesce(tickets.checked_in_count, 0) AS checked_in_count",
      "coalesce(ticket_payments.total_paid, 0) AS tickets_total_paid",
      "coalesce(donations.payment_total, 0) AS donations_total_paid",
      "coalesce(ticket_payments.total_paid, 0) + coalesce(donations.payment_total, 0) AS total_paid"
    ]

    tickets_sub = Qx.select("event_id", "SUM(quantity) AS total", "SUM(tickets.checked_in::int) AS checked_in_count")
      .from("tickets")
      .group_by("event_id")
      .as("tickets")

    ticket_payments_subquery = Qx.select("payment_id", "MAX(event_id) AS event_id").from("tickets").group_by("payment_id").as("tickets")

    ticket_payments_sub = Qx.select("SUM(payments.gross_amount) AS total_paid", "tickets.event_id")
      .from(:payments)
      .join(ticket_payments_subquery, "payments.id=tickets.payment_id")
      .group_by("tickets.event_id")
      .as("ticket_payments")

    donations_sub = Qx.select("event_id", "SUM(payments.gross_amount) as payment_total")
      .from("donations")
      .group_by("event_id")
      .left_join("payments", "donations.id=payments.donation_id")
      .as("donations")

    selects = selects.concat(additional_selects)
    Qx.select(*selects)
      .from("events")
      .left_join(
        [tickets_sub, "tickets.event_id = events.id"],
        [donations_sub, "donations.event_id = events.id"],
        [ticket_payments_sub, "ticket_payments.event_id=events.id"]
      )
  end

  def self.with_event_ids(event_ids)
    return [] if event_ids.empty?

    QueryEventMetrics.expression.where("events.id in ($ids)", ids: event_ids).execute
  end

  def self.for_listings(id_type, id, params)
    selects = [
      "events.id",
      "events.name",
      "events.venue_name",
      "events.address",
      "events.city",
      "events.state_code",
      "events.zip_code",
      "events.start_datetime",
      "events.end_datetime",
      "events.organizer_email"
    ]

    exp = QueryEventMetrics.expression(selects)

    if id_type == "profile"
      exp = exp.and_where(["events.profile_id = $id", id: id])
    end
    if id_type == "nonprofit"
      exp = exp.and_where(["events.nonprofit_id = $id", id: id])
    end
    if params["active"].present?
      exp = exp
        .and_where(["events.end_datetime >= $date", date: Time.now])
        .and_where(["events.published = TRUE AND coalesce(events.deleted, FALSE) = FALSE"])
    end
    if params["past"].present?
      exp = exp
        .and_where(["events.end_datetime < $date", date: Time.now])
        .and_where(["events.published = TRUE AND coalesce(events.deleted, FALSE) = FALSE"])
    end
    if params["unpublished"].present?
      exp = exp.and_where(["coalesce(events.published, FALSE) = FALSE AND coalesce(events.deleted, FALSE) = FALSE"])
    end
    exp = exp.and_where(["events.deleted = TRUE"]) if params["deleted"].present?
    exp.execute
  end
end
