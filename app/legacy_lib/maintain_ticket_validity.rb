# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module MaintainTicketValidity
  # some tickets have invalid records. Find them.
  def self.get_invalid_tickets
    tickets = Ticket.includes({charge: [{supporter: [:nonprofit]}]}, {supporter: :nonprofit}, {payment: [{supporter: :nonprofit}, :nonprofit]}, {event: :nonprofit})
    tickets = tickets.map { |t| {ticket: t, issues: []} }

    invalid = []

    first_level(tickets)

    a, tickets = tickets.partition { |i| i[:issues].any? }
    invalid = invalid.concat a

    second_level(tickets)
    a, _ = tickets.partition { |i| i[:issues].any? }
    invalid.concat(a)
  end

  # some tickets have valid records, format a report of them
  def self.report(invalid_records)
    invalid_records.map { |t|
      ticket = t[:ticket]
      {
        ticket_id: ticket.id,
        ticket_supporter_id: ticket.supporter_id,
        event_id: ticket.event_id,
        event_name: ticket.event&.name,
        event_nonprofit_id: ticket.event&.nonprofit_id,
        event_nonprofit_name: ticket.event&.nonprofit&.name,
        supporter_id: ticket.supporter_id,
        supporter_name: ticket.supporter&.name,
        supporter_nonprofit_id: ticket.supporter&.nonprofit_id,
        supporter_nonprofit_name: ticket.supporter&.nonprofit&.name,
        payment_id: ticket.payment_id,
        payment_supporter_id: ticket.payment&.supporter_id,
        charge_id: ticket.charge_id,
        ticket_date: ticket.created_at,
        errors: t[:issues]
      }
    }
  end

  def self.has_no_supporter(t)
    if !t[:ticket].supporter
      t[:issues].push(:no_supporter)
    end
  end

  def self.has_no_event(t)
    if !t[:ticket].event
      t[:issues].push(:no_event)
    end
  end

  def self.first_level(tickets)
    tickets.each do |t|
      has_no_event(t)
      has_no_supporter(t)
    end
  end

  def self.event_and_supporter_no_match(t)
    if t[:ticket].event&.nonprofit != t[:ticket].supporter&.nonprofit
      t[:issues].push(:event_and_supporter_nps_dont_match)
    end
  end

  def self.payment_and_supporter_no_match(t)
    if t[:ticket].payment && (t[:ticket].payment&.supporter != t[:ticket].supporter)
      t[:issues].push(:payment_and_ticket_supporter_no_match)
    end
  end

  def self.charge_but_no_payment(t)
    if t[:ticket].charge && !t[:ticket].payment
      t[:issues].push(:charge_but_no_payment)
    end
  end

  def self.second_level(tickets)
    tickets.each do |t|
      event_and_supporter_no_match(t)
      payment_and_supporter_no_match(t)
      charge_but_no_payment(t)
    end
  end

  # some tickets have invalid records. Clean them up.
  def self.cleanup(invalid_tickets, profile_id)
    Qx.transaction do
      invalid_tickets.each do |t|
        if t[:issues].include?(:no_supporter) && t[:issues].include?(:no_event)
          next
        end
        if t[:issues].include?(:no_supporter)
          cleanup_for_no_supporter(t[:ticket])
        end

        if t[:issues].include?(:no_event)
          cleanup_for_no_event(t[:ticket], profile_id)
        end

        if t[:issues].include?(:event_and_supporter_nps_dont_match)
          cleanup_for_event_and_supporter_nps_dont_match(t[:ticket])
        end
      end
    end
  end

  def self.cleanup_for_no_supporter(ticket)
    np = ticket.event&.nonprofit
    if np && !Supporter.exists?(ticket.supporter_id)
      supporter = np.supporters.build
      supporter.deleted = true
      if ticket.supporter_id
        supporter.id = ticket.supporter_id
      end
      supporter.save!

      if !ticket.supporter_id
        ticket.supporter = supporter
        ticket.save!
      end
    end
  end

  def self.cleanup_for_no_event(ticket, profile_id)
    np = ticket.supporter&.nonprofit
    if np && !Event.exists?(ticket.event_id)
      event = np.events.build
      event.deleted = true
      event.name = "Unnamed event #{ticket.event_id || rand(3000)}"
      event.start_datetime = ticket.created_at
      event.end_datetime = ticket.created_at + 1.hour
      event.address = "unknown"
      event.city = "city"
      event.state_code = "wi"
      event.zip_code = "55555"
      event.profile_id = profile_id
      event.slug = "unnamed_event__#{rand(4400)}"
      if ticket.event_id
        event.id = ticket.event_id
      end
      event.save!
    end
  end

  def self.cleanup_for_event_and_supporter_nps_dont_match(ticket)
    np = ticket.event.nonprofit
    old_supporter = ticket.supporter
    supporter = np.supporters.build
    supporter.name = old_supporter.name
    supporter.email = old_supporter.email
    supporter.phone = old_supporter.phone
    supporter.organization = old_supporter.organization
    supporter.address = old_supporter.address
    supporter.city = old_supporter.city
    supporter.state_code = old_supporter.state_code
    supporter.zip_code = old_supporter.zip_code
    supporter.country = old_supporter.country
    supporter.deleted = true
    supporter.save!

    ticket.supporter = supporter
    ticket.save!
  end

  def self.find_ticket_groups
    payments = Ticket.select("payment_id").where("payment_id IS NOT NULL").group("payment_id").map { |i| i.payment_id }

    payments.select do |p|
      tickets = Ticket.where("payment_id = ? ", p)
      supporter = tickets.first.supporter_id
      !tickets.all? { |t| t.supporter_id == supporter }
    end
  end
end
