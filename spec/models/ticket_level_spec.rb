# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe TicketLevel, type: :model do
  include_context :shared_donation_charge_context
  let(:ticket_level_name) { "TICKET LEVEL" }
  let(:order) { 3 }
  let(:free_amount) { 0 }
  let(:non_free_amount) { 7500 }
  let(:ticket_limit) { 4 }
  let(:description) { "Description" }

  let(:ticket_level_1) {
    event.ticket_levels.create(
      name: ticket_level_name,
      limit: ticket_limit,
      admin_only: true,
      order: order,
      amount: free_amount,
      description: description
    )
  }

  let(:ticket_level_2) {
    event.ticket_levels.create(
      name: ticket_level_name,
      limit: nil,
      admin_only: false,
      order: order,
      amount: non_free_amount,
      description: description
    )
  }

  describe "create" do
    describe "ticket_level_1" do
      it "is without error" do
        expect(ticket_level_1.errors).to be_empty
      end

      it "announces create" do
        expect(Houdini.event_publisher).to receive(:announce).with(:ticket_level_created, {
          "id" => match(/objevt_[a-zA-Z0-9]{22}/),
          "object" => "object_event",
          "type" => "ticket_level.created",
          "data" => {
            "object" => {
              "amount" => {"cents" => 0, "currency" => "usd"},
              "available_to" => "admins",
              "deleted" => false,
              "description" => description,
              "event" => {
                "id" => event.id,
                "name" => event.name,
                "object" => "event",
                "nonprofit" => nonprofit.id
              },
              "id" => kind_of(Numeric),
              "limit" => 4,
              "name" => ticket_level_name,
              "nonprofit" => {
                "id" => nonprofit.id,
                "name" => nonprofit.name,
                "object" => "nonprofit"
              },
              "event_discounts" => [],
              "object" => "ticket_level",
              "order" => order
            }
          }
        })

        ticket_level_1
      end
    end

    describe "ticket_level_2" do
      it "is without error" do
        expect(ticket_level_2.errors).to be_empty
      end

      it "announces create" do
        expect(Houdini.event_publisher).to receive(:announce).with(:ticket_level_created, {
          "id" => match(/objevt_[a-zA-Z0-9]{22}/),
          "object" => "object_event",
          "type" => "ticket_level.created",
          "data" => {
            "object" => {
              "amount" => {"cents" => non_free_amount, "currency" => "usd"},
              "available_to" => "everyone",
              "deleted" => false,
              "description" => description,
              "event" => {
                "id" => event.id,
                "name" => event.name,
                "object" => "event",
                "nonprofit" => nonprofit.id
              },
              "id" => kind_of(Numeric),
              "limit" => nil,
              "name" => ticket_level_name,
              "nonprofit" => {
                "id" => nonprofit.id,
                "name" => nonprofit.name,
                "object" => "nonprofit"
              },
              "event_discounts" => [],
              "object" => "ticket_level",
              "order" => order
            }
          }
        })

        ticket_level_2
      end
    end
  end

  describe "update" do
    describe "ticket_level_1" do
      it "is without error" do
        ticket_level_1.amount = 5000
        ticket_level_1.save
        expect(ticket_level_1.errors).to be_empty
      end

      it "announces updated" do
        expect(Houdini.event_publisher).to receive(:announce).with(:ticket_level_created, anything).ordered
        expect(Houdini.event_publisher).to receive(:announce).with(:ticket_level_updated, {
          "id" => match(/objevt_[a-zA-Z0-9]{22}/),
          "object" => "object_event",
          "type" => "ticket_level.updated",
          "data" => {
            "object" => {
              "amount" => {"cents" => 5000, "currency" => "usd"},
              "available_to" => "admins",
              "deleted" => false,
              "description" => description,
              "event" => {
                "id" => event.id,
                "name" => event.name,
                "object" => "event",
                "nonprofit" => nonprofit.id
              },
              "id" => kind_of(Numeric),
              "limit" => 4,
              "name" => ticket_level_name,
              "nonprofit" => {
                "id" => nonprofit.id,
                "name" => nonprofit.name,
                "object" => "nonprofit"
              },
              "event_discounts" => [],
              "object" => "ticket_level",
              "order" => order
            }
          }
        })

        ticket_level_1
        ticket_level_1.amount = 5000
        ticket_level_1.save
      end
    end

    describe "ticket_level_2" do
      it "is without error" do
        ticket_level_2.amount = 0
        ticket_level_2.save
        expect(ticket_level_2.errors).to be_empty
      end

      it "announces updated" do
        expect(Houdini.event_publisher).to receive(:announce).with(:ticket_level_created, anything).ordered
        expect(Houdini.event_publisher).to receive(:announce).with(:ticket_level_updated, {
          "id" => match(/objevt_[a-zA-Z0-9]{22}/),
          "object" => "object_event",
          "type" => "ticket_level.updated",
          "data" => {
            "object" => {
              "amount" => {"cents" => 0, "currency" => "usd"},
              "available_to" => "everyone",
              "deleted" => false,
              "description" => description,
              "event" => {
                "id" => event.id,
                "name" => event.name,
                "object" => "event",
                "nonprofit" => nonprofit.id
              },
              "id" => kind_of(Numeric),
              "limit" => nil,
              "name" => ticket_level_name,
              "nonprofit" => {
                "id" => nonprofit.id,
                "name" => nonprofit.name,
                "object" => "nonprofit"
              },
              "event_discounts" => [],
              "object" => "ticket_level",
              "order" => order
            }
          }
        })

        ticket_level_2
        ticket_level_2.amount = 0
        ticket_level_2.save
      end
    end
  end

  describe "deleted" do
    describe "ticket_level_1" do
      it "is without error" do
        ticket_level_1.discard!
        expect(ticket_level_1.deleted).to eq true
      end

      it "announces deleted" do
        expect(Houdini.event_publisher).to receive(:announce).with(:ticket_level_created, anything).ordered
        expect(Houdini.event_publisher).to receive(:announce).with(:ticket_level_deleted, {
          "id" => match(/objevt_[a-zA-Z0-9]{22}/),
          "object" => "object_event",
          "type" => "ticket_level.deleted",
          "data" => {
            "object" => {
              "amount" => {"cents" => 0, "currency" => "usd"},
              "available_to" => "admins",
              "deleted" => true,
              "description" => description,
              "event" => {
                "id" => event.id,
                "name" => event.name,
                "object" => "event",
                "nonprofit" => nonprofit.id
              },
              "id" => kind_of(Numeric),
              "limit" => 4,
              "name" => ticket_level_name,
              "nonprofit" => {
                "id" => nonprofit.id,
                "name" => nonprofit.name,
                "object" => "nonprofit"
              },
              "event_discounts" => [],
              "object" => "ticket_level",
              "order" => order
            }
          }
        }).ordered

        ticket_level_1.discard!
      end
    end

    describe "ticket_level_2" do
      it "is without error" do
        expect(ticket_level_2.errors).to be_empty
      end

      it "announces deleted" do
        expect(Houdini.event_publisher).to receive(:announce).with(:ticket_level_created, anything).ordered
        expect(Houdini.event_publisher).to receive(:announce).with(:ticket_level_deleted, {
          "id" => match(/objevt_[a-zA-Z0-9]{22}/),
          "object" => "object_event",
          "type" => "ticket_level.deleted",
          "data" => {
            "object" => {
              "amount" => {"cents" => non_free_amount, "currency" => "usd"},
              "available_to" => "everyone",
              "deleted" => true,
              "description" => description,
              "event" => {
                "id" => event.id,
                "name" => event.name,
                "object" => "event",
                "nonprofit" => nonprofit.id
              },
              "id" => kind_of(Numeric),
              "limit" => nil,
              "name" => ticket_level_name,
              "nonprofit" => {
                "id" => nonprofit.id,
                "name" => nonprofit.name,
                "object" => "nonprofit"
              },
              "event_discounts" => [],
              "object" => "ticket_level",
              "order" => order
            }
          }
        })

        ticket_level_2.discard!
      end
    end
  end
end
