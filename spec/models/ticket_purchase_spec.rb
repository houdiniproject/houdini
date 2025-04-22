# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe TicketPurchase, type: :model do
  include_context :shared_donation_charge_context

  describe "to_builder" do
    include_context :shared_donation_charge_context

    let(:legacy_free_tickets) do
      force_create(:ticket,
        event: event,
        supporter: supporter,
        ticket_level: free_ticket_level,
        quantity: 4)
    end

    let(:legacy_nonfree_tickets) do
      force_create(:ticket,
        event: event,
        supporter: supporter,
        ticket_level: ticket_level,
        quantity: 3)
    end

    describe "full-priced tickets" do
      # TODO Why are we manually setting everything here? It's not clear what order things should
      # go in for a transaction. Therefore, we don't assume the order for now and just make sure the
      # the output of to_builder is right
      let(:trx) { force_create(:transaction, supporter: supporter, amount: 1200) }

      let(:ticket_purchase) { force_create(:ticket_purchase, trx: trx, event: event, amount: 1200) }

      let(:tickets_for_ticket_purchase) do
        legacy_free_tickets.quantity.times do |i|
          ticket_purchase.ticket_to_legacy_tickets.create(ticket: legacy_free_tickets, amount: legacy_free_tickets.ticket_level.amount)
        end
        legacy_nonfree_tickets.quantity.times do |i|
          ticket_purchase.ticket_to_legacy_tickets.create(ticket: legacy_nonfree_tickets, amount: legacy_nonfree_tickets.ticket_level.amount)
        end
      end

      let(:tktpur_default) do
        {
          "id" => match_houid("tktpur"),
          "object" => "ticket_purchase",
          "nonprofit" => nonprofit.id,
          "event" => event.id,
          "supporter" => supporter.id,
          "tickets" => match_array(ticket_purchase.ticket_to_legacy_tickets.pluck(:id)),
          "amount" => {"currency" => "usd", "cents" => 1200},
          "original_discount" => {"percent" => 0},
          "event_discount" => nil,
          "transaction" => trx.id,
          "type" => "trx_assignment"
        }
      end

      it "is valid" do
        expect(ticket_purchase.to_builder.attributes!).to match(tktpur_default)
      end
    end
  end
end
