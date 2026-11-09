# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module QueryEventMetrics
  EVENT_COLUMNS = %i[id name venue_name address city state_code zip_code start_datetime end_datetime organizer_email in_person_or_virtual].freeze

  def self.with_event_ids(event_ids)
    return [] if event_ids.blank?

    add_metrics_to_events(Event.select(*EVENT_COLUMNS).where(id: event_ids))
  end

  def self.for_listings(id_type, id, params)
    add_metrics_to_events(listing_events(id_type, id, params))
  end

  def self.listing_events(id_type, id, params)
    events = Event.select(*EVENT_COLUMNS)

    events = case id_type
    when "profile" then events.where(profile_id: id)
    when "nonprofit" then events.where(nonprofit_id: id)
    else raise ArgumentError, "Unknown id_type #{id_type}"
    end

    if params["active"].present?
      events = events.where("end_datetime >= ?", Time.current).where(published: true).where("COALESCE(deleted, FALSE) = FALSE")
    elsif params["past"].present?
      events = events.where("end_datetime < ?", Time.current).where(published: true).where("COALESCE(deleted, FALSE) = FALSE")
    elsif params["unpublished"].present?
      events = events.where("COALESCE(published, FALSE) = FALSE").where("COALESCE(deleted, FALSE) = FALSE")
    elsif params["deleted"].present?
      events = events.where(deleted: true)
    end

    events.order(end_datetime: :desc)
  end

  def self.add_metrics_to_events(events)
    events = events.to_a
    return [] if events.empty?

    event_ids = events.map(&:id)
    tickets = ticket_metrics(event_ids)
    ticket_payments = ticket_payment_totals(event_ids)
    donations = donation_totals(event_ids)

    events.map do |event|
      total_attendees, checked_in_count = tickets.fetch(event.id, [0, 0])
      tickets_total_paid = ticket_payments.fetch(event.id, 0)
      donations_total_paid = donations.fetch(event.id, 0)

      EVENT_COLUMNS.to_h { |column| [column.to_s, event[column]] }.merge(
        "total_attendees" => total_attendees,
        "checked_in_count" => checked_in_count,
        "tickets_total_paid" => tickets_total_paid,
        "donations_total_paid" => donations_total_paid,
        "total_paid" => tickets_total_paid + donations_total_paid
      )
    end
  end

  # {event_id => [total attendees, checked in count]}
  def self.ticket_metrics(event_ids)
    Ticket.where(event_id: event_ids)
      .group(:event_id)
      .pluck(:event_id, Arel.sql("COALESCE(SUM(quantity), 0)"), Arel.sql("COALESCE(SUM(checked_in::int), 0)"))
      .to_h { |event_id, total, checked_in| [event_id, [total, checked_in]] }
  end

  # {event_id => sum of ticket payments}
  #
  # One checkout with several ticket levels creates several ticket rows that
  # share one payment, so each payment is counted once, against the latest
  # event among its tickets.
  def self.ticket_payment_totals(event_ids)
    payment_events = Ticket
      .where(payment_id: Ticket.where(event_id: event_ids).select(:payment_id))
      .group(:payment_id)
      .select("payment_id, MAX(event_id) AS event_id")

    Payment
      .joins("JOIN (#{payment_events.to_sql}) ticket_payments ON ticket_payments.payment_id = payments.id")
      .group("ticket_payments.event_id")
      .sum(:gross_amount)
  end

  # {event_id => sum of donation payments}
  def self.donation_totals(event_ids)
    Donation.left_joins(:payments)
      .where(event_id: event_ids)
      .group(:event_id)
      .sum("payments.gross_amount")
  end
end
