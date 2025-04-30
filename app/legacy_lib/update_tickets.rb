# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module UpdateTickets
  def self.update(data, current_user = nil)
    ParamValidation.new(data, {
      event_id: {required: true, is_reference: true},
      ticket_id: {required: true, is_reference: true},
      token: {format: UUID::Regex},
      bid_id: {is_integer: true},
      # note: nothing to check?

      checked_in: {included_in: ["true", "false", true, false]}

    })

    entities = RetrieveActiveRecordItems.retrieve_from_keys(data, Event => :event_id, Ticket => :ticket_id)
    validate_entities(entities)
    edited = false
    if data[:token]
      source_token = QuerySourceToken.get_and_increment_source_token(data[:token], current_user)
      tokenizable = source_token.tokenizable
      QuerySourceToken.validate_source_token_type(source_token)

      ## does the card belong to the supporter?
      if tokenizable.holder != entities[:ticket_id].supporter
        raise ParamValidation::ValidationError.new("Supporter #{entities[:ticket_id].supporter.id} does not own card #{tokenizable.id}", key: :token)
      end

      entities[:ticket_id].source_token = source_token
      edited = true
    end

    if data[:note]
      entities[:ticket_id].note = data[:note]
      edited = true
    end

    if data[:bid_id]
      entities[:ticket_id].bid_id = data[:bid_id]
      edited = true
    end

    unless data[:checked_in].nil?
      entities[:ticket_id].checked_in = data[:checked_in]
      edited = true
    end

    entities[:ticket_id].save! if edited
    entities[:ticket_id]
  end

  def self.delete(event_id, ticket_id)
    Qx.update(:tickets)
      .set(deleted: true)
      .timestamps
      .where(id: ticket_id)
      .and_where(event_id: event_id)
      .execute
  end

  def self.delete_card_for_ticket(event_id, ticket_id)
    begin
      ParamValidation.new({event_id: event_id, ticket_id: ticket_id},
        event_id: {required: true, is_integer: true},
        ticket_id: {required: true, is_integer: true})
    rescue ParamValidation::ValidationError => e
      return {json: {error: "Validation error\n #{e.message}", errors: e.data}, status: :unprocessable_entity}
    end

    begin
      ticket = Ticket.where("id = ? and event_id = ?", ticket_id, event_id).limit(1).first!
      ticket.card = nil
      ticket.source_token = nil
      ticket.save!
      {json: {}, status: :ok}
    rescue ActiveRecord::RecordNotFound => e
      # there's no stinking ticket by that event and ticket
      {json: {error: "No ticket with id #{ticket_id} at event with id #{event_id}\n #{e.message}"},
       status: :unprocessable_entity}
    rescue ActiveRecord::ActiveRecordError
      {json: {error: "There was a DB error. Please contact support"},
       status: :unprocessable_entity}
    end
  end

  def self.validate_entities(entities)
    if entities[:ticket_id].deleted
      raise ParamValidation::ValidationError.new("Ticket ID #{entities[:ticket_id].id} is deleted", key: :ticket_id)
    end

    if entities[:event_id].deleted
      raise ParamValidation::ValidationError.new("Event ID #{entities[:event_id].id} is deleted", key: :event_id)
    end

    if entities[:ticket_id].event != entities[:event_id]
      raise ParamValidation::ValidationError.new("Ticket ID #{entities[:ticket_id].id} does not belong to event #{entities[:event_id].id}", key: :ticket_id)
    end
  end

  def self.discount_ticket(ticket, discount)
    if ticket.class != Ticket
      ticket = Ticket.find(ticket)
    end

    if discount > 1 || discount < 0
      raise ArgumentError.new("Discount must be between 0 and 1. Value was #{discount}")
    end

    Qx.transaction do
      payment = ticket.payment
      payment.gross_amount = payment.gross_amount * (1 - discount)
      payment.net_amount = payment.net_amount * (1 - discount)
      payment.save!

      op = payment.offsite_payment
      op.gross_amount = op.gross_amount * (1 - discount)
      op.save!

      activities = ticket.activities.select { |i| i.action_type == "created" }
      activities.each do |a|
        data = JSON.parse(a.json_data)
        data["gross_amount"] = Integer(data["gross_amount"] * (1 - discount))
        a.json_data = JSON.generate(data)
        a.save!
      end
    end
  end
end
