# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module UpdateTickets
  def self.update(data, current_user = nil)
    ParamValidation.new(data,
      event_id: {required: true, is_reference: true},
      ticket_id: {required: true, is_reference: true},
      token: {format: UUID::Regex},
      bid_id: {is_integer: true},
      # note: nothing to check?

      checked_in: {included_in: ["true", "false", true, false]})

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

    publish_ticket_updated = false
    if data[:note]
      entities[:ticket_id].note = data[:note]
      edited = true
      publish_ticket_updated = true
    end

    if data[:bid_id]
      entities[:ticket_id].bid_id = data[:bid_id]
      edited = true
      publish_ticket_updated = true
    end

    unless data[:checked_in].nil?
      entities[:ticket_id].checked_in = data[:checked_in]
      edited = true
      publish_ticket_updated = true
    end

    entities[:ticket_id].save! if edited
    entities[:ticket_id].ticket_to_legacy_tickets.each(&:publish_updated) if publish_ticket_updated
    entities[:ticket_id]
  end

  def self.delete(event_id, ticket_id)
    Ticket.transaction do
      ticket = Event.find(event_id).tickets.find(ticket_id)
      ticket.deleted = true
      ticket.save!
      ticket.ticket_to_legacy_tickets.each(&:publish_deleted)
    end
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
end
