# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

module InsertTickets
  # Will generate rows for payment, offsite_payment or charge, tickets, activities
  # pass in:
  # data: {
  #   tickets: [{quantity, ticket_level_id}],
  #   event_id,
  #   nonprofit_id,
  #   supporter_id,
  #   event_discount_id,
  #   card_id, (if a charge)
  #   offsite_payment: {kind, check_number},
  #   kind (offsite, charge, or free)
  # }
  def self.create(data)
    data = data.with_indifferent_access
    ParamValidation.new(data,
      tickets: {required: true, is_array: true},
      nonprofit_id: {required: true, is_reference: true},
      supporter_id: {required: true, is_reference: true},
      event_id: {required: true, is_reference: true},
      event_discount_id: {is_reference: true},
      kind: {included_in: %w[free charge offsite]},
      token: {format: UUID::Regex},
      offsite_payment: {is_hash: true})

    data[:tickets].each do |t|
      ParamValidation.new(t, quantity: {is_integer: true, required: true, min: 1}, ticket_level_id: {is_reference: true, required: true})
    end

    ParamValidation.new(data[:offsite_payment], kind: {included_in: %w[cash check]}) if data[:offsite_payment] && !data[:offsite_payment][:kind].blank?

    entities = RetrieveActiveRecordItems.retrieve_from_keys(data, Supporter => :supporter_id, Nonprofit => :nonprofit_id, Event => :event_id)

    entities.merge!(RetrieveActiveRecordItems.retrieve_from_keys(data, {EventDiscount => :event_discount_id}, true))

    tl_entities = get_ticket_level_entities(data)

    validate_entities(entities, tl_entities)

    # verify that enough tickets_available
    QueryTicketLevels.verify_tickets_available(data[:tickets])

    gross_amount = QueryTicketLevels.gross_amount_from_tickets(data[:tickets], data[:event_discount_id])

    result = {}

    trx = entities[:supporter_id].transactions.build(amount: gross_amount)
    subtrx = nil
    if gross_amount > 0
      # Create offsite payment for tickets
      if data[:kind] == "offsite"
        current_user = data[:current_user]
        # offsite can only come from valid nonprofit users
        unless current_user && QueryRoles.is_authorized_for_nonprofit?(current_user.id, entities[:nonprofit_id].id)
          raise AuthenticationError
        end

        # create payment and offsite payment
        result["payment"] = create_payment(entities, gross_amount)
        result["offsite_payment"] = create_offsite_payment(entities, gross_amount, data, result["payment"])
        subtrx = trx.build_subtransaction(
          subtransactable: OfflineTransaction.new(amount: gross_amount),
          payments: [
            SubtransactionPayment.new(
              paymentable: OfflineTransactionCharge.new(payment: Payment.find(result["payment"]["id"]))
            )
          ],
          created: data["date"]
        )

      # Create charge for tickets
      elsif data["kind"] == "charge" || !data["kind"]
        source_token = QuerySourceToken.get_and_increment_source_token(data[:token], nil)
        QuerySourceToken.validate_source_token_type(source_token)
        tokenizable = source_token.tokenizable
        ## does the card belong to the supporter?
        if tokenizable.holder != entities[:supporter_id]
          raise ParamValidation::ValidationError.new("Supporter #{entities[:supporter_id].id} does not own card #{tokenizable.id}", key: :token)
        end

        result = result.merge(InsertCharge.with_stripe(
          kind: "Ticket",
          towards: entities[:event_id].name,
          metadata: {kind: "Ticket", event_id: entities[:event_id].id, nonprofit_id: entities[:nonprofit_id].id},
          statement: "Tickets #{entities[:event_id].name}",
          amount: gross_amount,
          nonprofit_id: entities[:nonprofit_id].id,
          supporter_id: entities[:supporter_id].id,
          card_id: tokenizable.id
        ))
        if result["charge"]["status"] == "failed"
          raise ChargeError, result["charge"]["failure_message"]
        else
          subtrx = trx.build_subtransaction(
            subtransactable: StripeTransaction.new(amount: gross_amount),
            payments: [
              SubtransactionPayment.new(
                paymentable: StripeCharge.new(payment: Payment.find(result["payment"]["id"]))
              )
            ],
            created: Time.current
          )
        end
      else
        raise ParamValidation::ValidationError.new("Ticket costs money but you didn't pay.", key: :kind)
      end
    end

    ticket_purchase = trx.ticket_purchases.build(event: entities[:event_id])
    # Generate the bid ids
    data["tickets"] = generate_bid_ids(entities[:event_id].id, tl_entities)

    result["tickets"] = generated_ticket_entities(data["tickets"], result, entities)
    result["tickets"].each do |legacy_ticket|
      legacy_ticket.quantity.times do
        ticket_purchase.ticket_to_legacy_tickets.build(ticket: legacy_ticket)
      end
    end

    # Create the activity rows for the tickets
    InsertActivities.for_tickets(result["tickets"].map(&:id))

    result["tickets"].map(&:id)
    result["charge"] ? result["charge"].id : nil
    trx.save!
    ticket_purchase.save!
    if subtrx
      subtrx.save!
      subtrx.payments.each(&:publish_created)
      subtrx.publish_created
    end
    ticket_purchase.ticket_to_legacy_tickets.each(&:publish_created)
    ticket_purchase.publish_created
    trx.publish_created

    result
  end

  # Generate a set of 'bid ids' (ids for each ticket scoped within the event)
  def self.generate_bid_ids(event_id, tickets)
    # Generate the bid ids
    last_bid_id = Psql.execute(
      Qexpr.new.select("COUNT(*)").from(:tickets)
      .where("event_id=$id", id: event_id)
    ).first["count"].to_i
    tickets.zip(last_bid_id + 1..last_bid_id + tickets.count).map { |h, id| h.merge("bid_id" => id) }
  end

  # not really needed but used for breaking into the unit test and getting the IDs
  def self.generated_ticket_entities(ticket_data, result, entities)
    ticket_data.map do |ticket_request|
      t = Ticket.new
      t.quantity = ticket_request["quantity"]
      t.ticket_level = ticket_request["ticket_level_id"]
      t.event = entities[:event_id]
      t.supporter = entities[:supporter_id]
      t.payment = result["payment"]
      t.charge = result["charge"]
      t.bid_id = ticket_request["bid_id"]
      t.event_discount = entities[:event_discount_id]
      t.save!
      t
    end.to_a
  end

  def self.validate_entities(entities, tl_entities)
    ## is supporter deleted? If supporter is deleted, we error!
    if entities[:supporter_id].deleted
      raise ParamValidation::ValidationError.new("Supporter #{entities[:supporter_id].id} is deleted", key: :supporter_id)
    end

    if entities[:event_id].deleted
      raise ParamValidation::ValidationError.new("Event #{entities[:event_id].id} is deleted", key: :event_id)
    end

    # verify that enough tickets_available
    tl_entities.each do |i|
      if i[:ticket_level_id].deleted
        raise ParamValidation::ValidationError.new("Ticket level #{i[:ticket_level_id].id} is deleted", key: :tickets)
      end

      if i[:ticket_level_id].event != entities[:event_id]
        raise ParamValidation::ValidationError.new("Ticket level #{i[:ticket_level_id].id} does not belong to event #{entities[:event_id]}", key: :tickets)
      end
    end

    # Does the supporter belong to the nonprofit?
    if entities[:supporter_id].nonprofit != entities[:nonprofit_id]
      raise ParamValidation::ValidationError.new("Supporter #{entities[:supporter_id].id} does not belong to nonprofit #{entities[:nonprofit_id].id}", key: :supporter_id)
    end

    ## does event belong to nonprofit
    if entities[:event_id].nonprofit != entities[:nonprofit_id]
      raise ParamValidation::ValidationError.new("Event #{entities[:event_id].id} does not belong to nonprofit #{entities[:nonprofit_id]}", key: :event_id)
    end

    if entities[:event_discount_id] && entities[:event_discount_id].event != entities[:event_id]
      raise ParamValidation::ValidationError.new("Event discount #{entities[:event_discount_id].id} does not belong to event #{entities[:event_id].id}", key: :event_discount_id)
    end
  end

  def self.get_ticket_level_entities(data)
    data[:tickets].map do |i|
      {
        quantity: i[:quantity],
        ticket_level_id: RetrieveActiveRecordItems.retrieve_from_keys(i, TicketLevel => :ticket_level_id)[:ticket_level_id]
      }
    end.to_a
  end

  def self.create_payment(entities, gross_amount)
    p = Payment.new
    p.gross_amount = gross_amount
    p.nonprofit = entities[:nonprofit_id]
    p.supporter = entities[:supporter_id]
    p.refund_total = 0
    p.date = Time.current
    p.towards = entities[:event_id].name
    p.fee_total = 0
    p.net_amount = gross_amount
    p.kind = "OffsitePayment"
    p.save!
    p
  end

  def self.create_offsite_payment(entities, gross_amount, data, payment)
    p = OffsitePayment.new
    p.gross_amount = gross_amount
    p.nonprofit = entities[:nonprofit_id]
    p.supporter = entities[:supporter_id]
    p.date = Time.current
    p.payment = payment
    p.kind = data["offsite_payment"]["kind"]
    p.check_number = data["offsite_payment"]["check_number"]
    p.save!
    p
  end
end
