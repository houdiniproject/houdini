# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe UpdateTickets do
  let(:ticket) {
    Event.any_instance.stub(:geocode).and_return([1, 1])
    create(:ticket, :has_card, :has_event)
  }

  describe ".update" do
    include_context :shared_rd_donation_value_context

    let(:basic_valid_ticket_input) {
      {ticket_id: ticket.id, event_id: event.id}
    }
    let(:include_fake_token) {
      basic_valid_ticket_input.merge({token: fake_uuid})
    }

    let(:include_valid_token) {
      basic_valid_ticket_input.merge({token: source_token.token})
    }

    let(:general_ticket) {
      {
        quantity: 1,
        supporter: supporter,
        payment: payment,
        charge: charge,
        event_discount: event_discount,
        created_at: Time.now,
        updated_at: Time.now,
        checked_in: nil,
        bid_id: 1,
        card_id: nil,
        profile_id: nil,
        note: nil,
        deleted: false,
        source_token_id: nil,
        ticket_level_id: nil
      }
    }

    let(:general_expected) {
      {
        id: ticket.id,
        quantity: 1,
        supporter_id: supporter.id,
        payment_id: payment.id,
        charge_id: charge.id,
        event_discount_id: event_discount.id,
        created_at: Time.now,
        updated_at: Time.now,
        checked_in: nil,
        bid_id: 1,
        card_id: nil,
        profile_id: nil,
        note: nil,
        deleted: false,
        source_token_id: nil,
        event_id: event.id,
        ticket_level_id: nil,
        ticket_purchase_id: nil
      }.with_indifferent_access
    }

    let(:payment) { force_create(:payment) }
    let(:charge) { force_create(:charge) }

    let(:ticket) {
      force_create(:ticket,
        general_ticket.merge(event: event))
    }

    let(:other_ticket) {
      force_create(:ticket,
        general_ticket.merge(event: other_event))
    }

    it "basic validation" do
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
      find_error_event { UpdateTickets.update(event_id: 5555, ticket_id: ticket.id) }
    end

    it "ticket is invalid" do
      find_error_ticket { UpdateTickets.update(event_id: event.id, ticket_id: 5555) }
    end

    it "ticket is deleted" do
      ticket.deleted = true
      ticket.save!

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

      expect { UpdateTickets.update(event_id: event.id, ticket_id: ticket.id) }.to raise_error { |error|
        expect(error).to be_a ParamValidation::ValidationError
        expect_validation_errors(error.data, [{key: :event_id}])
        expect(error.message).to include "deleted"
        expect(error.message).to include "Event ID #{event.id}"
      }
    end

    it "event and ticket dont match" do
      expect { UpdateTickets.update(event_id: event.id, ticket_id: other_ticket.id) }.to raise_error { |error|
        expect(error).to be_a ParamValidation::ValidationError
        expect_validation_errors(error.data, [{key: :ticket_id}])
        expect(error.message).to include "Ticket ID #{other_ticket.id} does not belong to event #{event.id}"
      }
    end

    it "token is invalid" do
      validation_invalid_token { UpdateTickets.update(include_fake_token) }
    end

    it "errors out if token is unauthorized" do
      validation_unauthorized { UpdateTickets.update(include_fake_token) }
    end

    it "errors out if token is expired" do
      validation_expired { UpdateTickets.update(include_fake_token) }
    end

    it "card doesnt belong to supporter" do
      validation_card_not_with_supporter { UpdateTickets.update(include_fake_token.merge({token: other_source_token.token})) }
    end

    it "success editing note" do
      result = UpdateTickets.update(basic_valid_ticket_input.merge(note: "noteedited"))
      expected = general_expected.merge(note: "noteedited")

      expect(result.attributes).to eq expected
      ticket.reload
      expect(ticket.attributes).to eq expected
    end

    it "success editing bid_id" do
      result = UpdateTickets.update(basic_valid_ticket_input.merge(bid_id: 50))
      expected = general_expected.merge(bid_id: 50)

      expect(result.attributes).to eq expected
      ticket.reload
      expect(ticket.attributes).to eq expected
    end

    it "success editing checked_in" do
      result = UpdateTickets.update(basic_valid_ticket_input.merge(checked_in: "true"))
      expected = general_expected.merge(checked_in: true)

      expect(result.attributes).to eq expected
      ticket.reload
      expect(ticket.attributes).to eq expected
    end

    it "success editing checked_in as a boolean" do
      result = UpdateTickets.update(basic_valid_ticket_input.merge(checked_in: true))
      expected = general_expected.merge(checked_in: true)

      expect(result.attributes).to eq expected
      ticket.reload
      expect(ticket.attributes).to eq expected
    end

    it "success editing token" do
      result = UpdateTickets.update(basic_valid_ticket_input.merge(token: source_token.token))
      expected = general_expected.merge(source_token_id: source_token.id)

      expect(result.attributes).to eq expected
      ticket.reload
      expect(ticket.attributes).to eq expected
    end
  end

  describe ".delete" do
    around(:each) do |ex|
      StripeMockHelper.mock do
        ex.run
      end
    end

    it "marks the given ticket as deleted=true" do
      UpdateTickets.delete(ticket["event_id"], ticket["id"])
      ticket.reload
      expect(ticket["deleted"]).to eq(true)

      expect(Ticket.count).to eq(1)
    end
  end

  describe ".delete_card_for_ticket" do
    around(:each) do |ex|
      StripeMockHelper.mock do
        ex.run
      end
    end
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
        skip_attribs = [:updated_at, :card]
        expect(ticket.attributes.select { |k, _| !skip_attribs.include?(k) }).to eq original_ticket.attributes.select { |k, _| !skip_attribs.include?(k) }

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
