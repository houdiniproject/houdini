# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe TicketToLegacyTicket, type: :model do
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
    let(:trx) { force_create(:transaction, supporter: supporter, amount: 1200) }

    let(:ticket_purchase) { force_create(:ticket_purchase, trx: trx, event: event) }

    let(:tickets_for_ticket_purchase) do
      legacy_free_tickets.quantity.times do |i|
        ticket_purchase.ticket_to_legacy_tickets.create(ticket: legacy_free_tickets, amount: legacy_free_tickets.ticket_level.amount)
      end
      legacy_nonfree_tickets.quantity.times do |i|
        ticket_purchase.ticket_to_legacy_tickets.create(ticket: legacy_nonfree_tickets, amount: legacy_nonfree_tickets.ticket_level.amount)
      end
    end

    let(:ticket_purchase_to_id) do
      {
        "id" => ticket_purchase.id,
        "object" => "ticket_purchase",
        "type" => "trx_assignment"
      }
    end

    let(:ticket_default) do
      {
        "id" => match_houid("tkt"),
        "checked_in" => false,
        "deleted" => false,
        "note" => nil,
        "object" => "ticket",
        "nonprofit" => nonprofit.id,
        "event" => event.id,
        "supporter" => supporter.id,
        "ticket_purchase" => ticket_purchase_to_id,
        "original_discount" => {"percent" => 0},
        "event_discount" => nil
      }
    end

    let(:free_ticket_default) {
      ticket_default.merge({
        "ticket_level" => legacy_free_tickets.ticket_level.id,
        "amount" => {"currency" => "usd", "cents" => 0}
      })
    }

    let(:nonfree_ticket_default) {
      ticket_default.merge({
        "ticket_level" => legacy_nonfree_tickets.ticket_level.id,
        "amount" => {"currency" => "usd", "cents" => legacy_nonfree_tickets.ticket_level.amount}
      })
    }

    subject {
      tickets_for_ticket_purchase
      TicketToLegacyTicket
    }

    it "has 7 TicketToLegacyTicket" do
      expect(subject.count).to eq 7
    end

    it "has 3 pointing at legacy_free_tickets" do
      expect(subject.where(ticket: legacy_free_tickets).count).to eq 4
    end

    it "has 4 pointing at legacy_nonfree_tickets" do
      expect(subject.where(ticket: legacy_nonfree_tickets).count).to eq 3
    end

    it "has a valid free_ticket" do
      expect(subject.where(ticket: legacy_free_tickets).first.to_builder.attributes!).to match(free_ticket_default)
    end

    it "has a valid nonfree  ticket" do
      expect(subject.where(ticket: legacy_nonfree_tickets).first.to_builder.attributes!).to match(nonfree_ticket_default)
    end

    it "has all free checked in" do
      legacy_free_tickets.checked_in = true
      legacy_free_tickets.note = "NOTE"
      legacy_free_tickets.deleted = true
      legacy_free_tickets.save!

      subject.where(ticket: legacy_free_tickets).each do |item|
        json = item.to_builder.attributes!
        expect(json).to match(free_ticket_default.merge({
          "deleted" => true,
          "checked_in" => true,
          "note" => "NOTE"
        }))
      end
    end
  end

  describe "discounted tickets" do
    let(:trx) { force_create(:transaction, supporter: supporter, amount: 960) }

    let(:ticket_purchase) { force_create(:ticket_purchase, trx: trx, event: event, event_discount: event_discount, original_discount: 20) }

    let(:tickets_for_ticket_purchase) do
      legacy_free_tickets.quantity.times do |i|
        ticket_purchase.ticket_to_legacy_tickets.create(ticket: legacy_free_tickets, amount: 0)
      end
      legacy_nonfree_tickets.quantity.times do |i|
        ticket_purchase.ticket_to_legacy_tickets.create(ticket: legacy_nonfree_tickets, amount: 320)
      end
    end

    let(:ticket_purchase_to_id) do
      {
        "id" => ticket_purchase.id,
        "object" => "ticket_purchase",
        "type" => "trx_assignment"
      }
    end

    let(:ticket_default) do
      {
        "id" => match_houid("tkt"),
        "checked_in" => false,
        "deleted" => false,
        "note" => nil,
        "object" => "ticket",
        "nonprofit" => nonprofit.id,
        "event" => event.id,
        "supporter" => supporter.id,
        "ticket_purchase" => ticket_purchase_to_id,
        "original_discount" => {"percent" => 20},
        "event_discount" => event_discount.id
      }
    end

    let(:free_ticket_default) {
      ticket_default.merge({
        "ticket_level" => legacy_free_tickets.ticket_level.id,
        "amount" => {"currency" => "usd", "cents" => 0}
      })
    }

    let(:nonfree_ticket_default) {
      ticket_default.merge({
        "ticket_level" => legacy_nonfree_tickets.ticket_level.id,
        "amount" => {"currency" => "usd", "cents" => 320}
      })
    }

    subject {
      tickets_for_ticket_purchase
      TicketToLegacyTicket
    }

    it "has 7 TicketToLegacyTicket" do
      expect(subject.count).to eq 7
    end

    it "has 3 pointing at legacy_free_tickets" do
      expect(subject.where(ticket: legacy_free_tickets).count).to eq 4
    end

    it "has 4 pointing at legacy_nonfree_tickets" do
      expect(subject.where(ticket: legacy_nonfree_tickets).count).to eq 3
    end

    it "has a valid free_ticket" do
      expect(subject.where(ticket: legacy_free_tickets).first.to_builder.attributes!).to match(free_ticket_default)
    end

    it "has a valid nonfree  ticket" do
      expect(subject.where(ticket: legacy_nonfree_tickets).first.to_builder.attributes!).to match(nonfree_ticket_default)
    end

    it "has all free checked in" do
      legacy_free_tickets.checked_in = true
      legacy_free_tickets.note = "NOTE"
      legacy_free_tickets.deleted = true
      legacy_free_tickets.save!

      subject.where(ticket: legacy_free_tickets).each do |item|
        json = item.to_builder.attributes!
        expect(json).to match(free_ticket_default.merge({
          "deleted" => true,
          "checked_in" => true,
          "note" => "NOTE"
        }))
      end
    end
  end
end
