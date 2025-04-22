# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe UpdateTickets do
  let(:ticket) do
    create(:ticket, :has_card, :has_event)
  end

  describe ".update" do
    include_context :shared_rd_donation_value_context
    let(:trx) { create(:transaction, supporter: supporter) }

    let(:basic_valid_ticket_input) do
      {ticket_id: ticket.id, event_id: event.id}
    end
    let(:include_fake_token) do
      basic_valid_ticket_input.merge(token: fake_uuid)
    end

    let(:include_valid_token) do
      basic_valid_ticket_input.merge(token: source_token.token)
    end

    let(:general_ticket) do
      {
        quantity: 2,
        supporter: supporter,
        payment: payment,
        charge: charge,
        event_discount: event_discount,
        created_at: Time.now,
        updated_at: Time.now,
        checked_in: false,
        bid_id: 1,
        card_id: nil,
        profile_id: nil,
        note: nil,
        deleted: false,
        source_token_id: nil,
        ticket_level_id: ticket_level.id
      }
    end

    let(:general_expected) do
      {
        id: ticket.id,
        quantity: 2,
        supporter_id: supporter.id,
        payment_id: payment.id,
        charge_id: charge.id,
        event_discount_id: event_discount.id,
        created_at: Time.now,
        updated_at: Time.now,
        checked_in: false,
        bid_id: 1,
        card_id: nil,
        profile_id: nil,
        note: nil,
        deleted: false,
        source_token_id: nil,
        event_id: event.id,
        ticket_level_id: ticket_level.id
      }.with_indifferent_access
    end

    let(:payment) { force_create(:payment) }
    let(:charge) { force_create(:charge) }

    let(:ticket) do
      tp = trx.ticket_purchases.create(event: event)

      ticket = force_create(:ticket,
        general_ticket.merge(event: event))
      ticket.quantity.times do
        ticket.ticket_to_legacy_tickets.create(ticket_purchase: tp)
      end
      ticket
    end

    let(:other_ticket) do
      ticket = force_create(:ticket,
        general_ticket.merge(event: other_event))
      ticket.quantity.times do
        ticket.ticket_to_legacy_tickets.create
      end
      ticket
    end

    def expect_ticket_updated_to_not_be_called
      expect(Houdini.event_publisher).to_not receive(:announce).with(:ticket_updated, any_args)
    end

    it "basic validation" do
      expect_ticket_updated_to_not_be_called
      expect { UpdateTickets.update(token: "bhaetiwhet", checked_in: "blah", bid_id: "bhalehti") }.to raise_error { |error|
        expect(error).to be_a ParamValidation::ValidationError

        expect_validation_errors(error.data, [
          {key: :event_id, name: :required},
          {key: :event_id, name: :is_reference},
          {key: :ticket_id, name: :required},
          {key: :ticket_id, name: :is_reference},
          {key: :token, name: :format},
          {key: :bid_id, name: :is_integer},
          {key: :checked_in, name: :included_in}
        ])
      }
    end

    it "event is invalid" do
      expect_ticket_updated_to_not_be_called
      find_error_event { UpdateTickets.update(event_id: 5555, ticket_id: ticket.id) }
    end

    it "ticket is invalid" do
      expect_ticket_updated_to_not_be_called
      find_error_ticket { UpdateTickets.update(event_id: event.id, ticket_id: 5555) }
    end

    it "ticket is deleted" do
      ticket.deleted = true
      ticket.save!
      expect_ticket_updated_to_not_be_called
      expect { UpdateTickets.update(event_id: event.id, ticket_id: ticket.id) }.to raise_error { |error|
        expect(error).to be_a ParamValidation::ValidationError
        expect_validation_errors(error.data, [{key: :ticket_id}])
        expect(error.message).to include "deleted"
        expect(error.message).to include "Ticket ID #{ticket.id}"
      }
    end

    it "event is deleted" do
      event.deleted = true
      event.save!
      expect_ticket_updated_to_not_be_called
      expect { UpdateTickets.update(event_id: event.id, ticket_id: ticket.id) }.to raise_error { |error|
        expect(error).to be_a ParamValidation::ValidationError
        expect_validation_errors(error.data, [{key: :event_id}])
        expect(error.message).to include "deleted"
        expect(error.message).to include "Event ID #{event.id}"
      }
    end

    it "event and ticket dont match" do
      expect_ticket_updated_to_not_be_called
      expect { UpdateTickets.update(event_id: event.id, ticket_id: other_ticket.id) }.to raise_error { |error|
        expect(error).to be_a ParamValidation::ValidationError
        expect_validation_errors(error.data, [{key: :ticket_id}])
        expect(error.message).to include "Ticket ID #{other_ticket.id} does not belong to event #{event.id}"
      }
    end

    it "token is invalid" do
      expect_ticket_updated_to_not_be_called
      validation_invalid_token { UpdateTickets.update(include_fake_token) }
    end

    it "errors out if token is unauthorized" do
      expect_ticket_updated_to_not_be_called
      validation_unauthorized { UpdateTickets.update(include_fake_token) }
    end

    it "errors out if token is expired" do
      expect_ticket_updated_to_not_be_called
      validation_expired { UpdateTickets.update(include_fake_token) }
    end

    it "card doesnt belong to supporter" do
      expect_ticket_updated_to_not_be_called
      validation_card_not_with_supporter { UpdateTickets.update(include_fake_token.merge(token: other_source_token.token)) }
    end

    it "success editing note" do
      allow(Houdini.event_publisher).to receive(:announce)
      expect(Houdini.event_publisher).to receive(:announce).with(:ticket_updated, any_args)
      result = UpdateTickets.update(basic_valid_ticket_input.merge(note: "noteedited"))
      expected = general_expected.merge(note: "noteedited")

      expect(result.attributes).to eq expected
      ticket.reload
      expect(ticket.attributes).to eq expected
    end

    it "success editing bid_id" do
      allow(Houdini.event_publisher).to receive(:announce)
      expect(Houdini.event_publisher).to receive(:announce).with(:ticket_updated, any_args)
      result = UpdateTickets.update(basic_valid_ticket_input.merge(bid_id: 50))
      expected = general_expected.merge(bid_id: 50)

      expect(result.attributes).to eq expected
      ticket.reload
      expect(ticket.attributes).to eq expected
    end

    it "success editing checked_in" do
      allow(Houdini.event_publisher).to receive(:announce)
      expect(Houdini.event_publisher).to receive(:announce).with(:ticket_updated, any_args)
      result = UpdateTickets.update(basic_valid_ticket_input.merge(checked_in: "true"))
      expected = general_expected.merge(checked_in: true)

      expect(result.attributes).to eq expected
      ticket.reload
      expect(ticket.attributes).to eq expected
    end

    it "success editing checked_in as a boolean" do
      allow(Houdini.event_publisher).to receive(:announce)
      expect(Houdini.event_publisher).to receive(:announce).with(:ticket_updated, any_args)
      result = UpdateTickets.update(basic_valid_ticket_input.merge(checked_in: true))
      expected = general_expected.merge(checked_in: true)

      expect(result.attributes).to eq expected
      ticket.reload
      expect(ticket.attributes).to eq expected
    end

    it "success editing token" do
      expect_ticket_updated_to_not_be_called
      result = UpdateTickets.update(basic_valid_ticket_input.merge(token: source_token.token))
      expected = general_expected.merge(source_token_id: source_token.id)

      expect(result.attributes).to eq expected
      ticket.reload
      expect(ticket.attributes).to eq expected
    end
  end

  describe ".delete" do
    include_context :shared_rd_donation_value_context
    let(:trx) { create(:transaction, supporter: supporter) }

    let(:basic_valid_ticket_input) do
      {ticket_id: ticket.id, event_id: event.id}
    end
    let(:include_fake_token) do
      basic_valid_ticket_input.merge(token: fake_uuid)
    end

    let(:include_valid_token) do
      basic_valid_ticket_input.merge(token: source_token.token)
    end

    let(:general_ticket) do
      {
        quantity: 2,
        supporter: supporter,
        payment: payment,
        charge: charge,
        event_discount: event_discount,
        created_at: Time.now,
        updated_at: Time.now,
        checked_in: false,
        bid_id: 1,
        card_id: nil,
        profile_id: nil,
        note: nil,
        deleted: false,
        source_token_id: nil,
        ticket_level_id: ticket_level.id
      }
    end

    let(:general_expected) do
      {
        id: ticket.id,
        quantity: 2,
        supporter_id: supporter.id,
        payment_id: payment.id,
        charge_id: charge.id,
        event_discount_id: event_discount.id,
        created_at: Time.now,
        updated_at: Time.now,
        checked_in: false,
        bid_id: 1,
        card_id: nil,
        profile_id: nil,
        note: nil,
        deleted: false,
        source_token_id: nil,
        event_id: event.id,
        ticket_level_id: ticket_level.id
      }.with_indifferent_access
    end

    let(:payment) { force_create(:payment) }
    let(:charge) { force_create(:charge) }

    let(:ticket) do
      tp = trx.ticket_purchases.create(event: event)

      ticket = force_create(:ticket,
        general_ticket.merge(event: event))
      ticket.quantity.times do
        ticket.ticket_to_legacy_tickets.create(ticket_purchase: tp)
      end
      ticket
    end

    it "marks the given ticket as deleted=true" do
      allow(Houdini.event_publisher).to receive(:announce)
      expect(Houdini.event_publisher).to_not receive(:announce).with(:ticket_updated, any_args)
      expect(Houdini.event_publisher).to receive(:announce).with(:ticket_deleted, any_args).exactly(ticket.quantity).times
      UpdateTickets.delete(ticket["event_id"], ticket["id"])
      ticket.reload
      expect(ticket["deleted"]).to eq(true)
      expect(ticket.ticket_to_legacy_tickets.all?(&:deleted)).to eq true
      expect(Ticket.count).to eq(1)
    end
  end

  describe ".delete_card_for_ticket" do
    it "deletes the card from the ticket" do
      Timecop.freeze(2020, 1, 5) do
        original_ticket = ticket
        card = ticket.card
        expect(ticket.card).to_not be_nil
        ret = UpdateTickets.delete_card_for_ticket(ticket["event_id"], ticket["id"])
        expect(ret[:status]).to eq :ok
        expect(ret[:json]).to eq({})
        ticket.reload
        expect(Card.find(card.id)).to eq(card)
        expect(ticket.card).to be_nil
        expect(Ticket.count).to eq(1)
        skip_attribs = %i[updated_at card]
        expect(ticket.attributes.reject { |k, _| skip_attribs.include?(k) }).to eq original_ticket.attributes.reject { |k, _| skip_attribs.include?(k) }

        expect(ticket.updated_at).to eq Time.now
      end
    end

    context "parameter validation" do
      it "validates parameters" do
        result = UpdateTickets.delete_card_for_ticket(nil, nil)
        errors = result[:json][:errors]
        expect(errors.length).to eq(4)
        expect(result[:status]).to eq :unprocessable_entity
        expect_validation_errors(errors, [
          {key: :event_id, name: :required},
          {key: :event_id, name: :is_integer},
          {key: :ticket_id, name: :required},
          {key: :ticket_id, name: :is_integer}
        ])
      end

      it "invalid event_id causes no problem" do
        ticket
        tickets = Ticket.all
        events = Event.all
        result = UpdateTickets.delete_card_for_ticket(444, ticket.id)
        expect(result[:status]).to eq :unprocessable_entity
        expect(Ticket.all).to match_array(tickets)
        expect(Event.all).to match_array(events)
      end

      it "invalid ticket_id causes no problem" do
        ticket
        tickets = Ticket.all
        events = Event.all
        result = UpdateTickets.delete_card_for_ticket(ticket.event.id, 444)
        expect(result[:status]).to eq :unprocessable_entity
        expect(Ticket.all).to match_array(tickets)
        expect(Event.all).to match_array(events)
      end
    end
  end
end
