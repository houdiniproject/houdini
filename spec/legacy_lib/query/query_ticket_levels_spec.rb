# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe QueryTicketLevels do
  include_context :shared_donation_charge_context
  describe ".gross_amount_from_tickets" do
    it "handles free tickets only properly" do
      result = QueryTicketLevels.gross_amount_from_tickets(["ticket_level_id" => free_ticket_level.id, "quantity" => 5], nil)
      expect(result).to eq 0
    end

    it "handles nonfree tickets only properly" do
      result = QueryTicketLevels.gross_amount_from_tickets(["ticket_level_id" => ticket_level.id, "quantity" => 5], nil)
      expect(result).to eq 2000
    end

    it "handles mix of tickets properly" do
      result = QueryTicketLevels.gross_amount_from_tickets(
        [{"ticket_level_id" => ticket_level.id, "quantity" => 5},
          {"ticket_level_id" => ticket_level2.id, "quantity" => 2},
          {"ticket_level_id" => free_ticket_level.id, "quantity" => 4000}], nil
      )
      expect(result).to eq 3000
    end

    it "handles mix of tickets properly with discount code properly" do
      result = QueryTicketLevels.gross_amount_from_tickets(
        [{"ticket_level_id" => ticket_level.id, "quantity" => 5},
          {"ticket_level_id" => ticket_level2.id, "quantity" => 2},
          {"ticket_level_id" => free_ticket_level.id, "quantity" => 4000}], event_discount.id
      )
      expect(result).to eq 2400
    end
  end

  describe ".verify_tickets_available" do
    let(:ticket_level_1) { force_create(:ticket_level, limit: 3, event: event) }
    let(:ticket_level_2) { force_create(:ticket_level, limit: 2, event: event) }
    let(:tickets) do
      [
        force_create(:ticket, ticket_level: ticket_level_1, quantity: 1),
        force_create(:ticket, ticket_level: ticket_level_1, quantity: 1)
      ]
    end

    it "fails when ticket level is too many" do
      expect do
        QueryTicketLevels.verify_tickets_available([
          {ticket_level_id: ticket_level_1.id, quantity: 50},
          {ticket_level_id: ticket_level_2.id, quantity: 1}
        ])
      end.to raise_error(NotEnoughQuantityError)
      expect do
        QueryTicketLevels.verify_tickets_available([
          {ticket_level_id: ticket_level_2.id, quantity: 3}
        ])
      end.to raise_error(NotEnoughQuantityError)
    end

    it "allows when a full item is at 0 and other is acceptable" do
      expect do
        QueryTicketLevels.verify_tickets_available([
          {ticket_level_id: ticket_level_1.id, quantity: 0},
          {ticket_level_id: ticket_level_2.id, quantity: 2}
        ])
      end.to_not raise_error
    end

    it "allows when only acceptable are passed " do
      expect do
        QueryTicketLevels.verify_tickets_available([
          {ticket_level_id: ticket_level_2.id, quantity: 2}
        ])
      end.to_not raise_error
    end
  end
end
