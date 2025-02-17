# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe EventDiscount, type: :model do
  include_context :shared_donation_charge_context
  let(:name) { "CUSTOM EVENT DISCOUNT" }
  let(:percent) { 55 }
  let(:code) { "fewet" }
  let(:event_discount) {
    ticket_level
    event.event_discounts.create(name: name, percent: percent, code: code)
  }

  describe "validate" do
    let(:event_discount) {
      ed = EventDiscount.new
      ed.save
      ed
    }
    let(:ed_percent_at_0) {
      ed = EventDiscount.new(percent: 0)
      ed.save
      ed
    }
    let(:ed_percent_at_101) {
      ed = EventDiscount.new(percent: 101)
      ed.save
      ed
    }

    it("has errors on name") do
      expect(event_discount.errors.details[:name].length).to be(1)
    end

    it("has errors on code") do
      expect(event_discount.errors.details[:code].length).to be(1)
    end

    it("has errors on event") do
      expect(event_discount.errors.details[:event].length).to be(1)
    end

    it("has errors on percent") do
      expect(event_discount.errors.details[:percent].length).to be(2)
    end

    it("has errors on percents at 0") do
      expect(ed_percent_at_0.errors.details[:percent].length).to be(1)
    end

    it("has errors on percents at 101") do
      expect(ed_percent_at_101.errors.details[:percent].length).to be(1)
    end
  end

  describe "create" do
    it "is without error" do
      expect(event_discount.errors).to be_empty
    end

    it "announces create" do
      expect(Houdini.event_publisher).to receive(:announce).with(:ticket_level_created, anything).ordered
      expect(Houdini.event_publisher).to receive(:announce).with(:event_discount_created, {
        "id" => match(/objevt_[a-zA-Z0-9]{22}/),
        "object" => "object_event",
        "type" => "event_discount.created",
        "data" => {
          "object" => {
            "code" => code,
            "deleted" => false,
            "discount" => {
              "percent" => percent
            },
            "event" => {
              "id" => event.id,
              "name" => event.name,
              "object" => "event",
              "nonprofit" => nonprofit.id
            },
            "id" => kind_of(Numeric),
            "name" => name,
            "nonprofit" => {
              "id" => nonprofit.id,
              "name" => nonprofit.name,
              "object" => "nonprofit"
            },
            "object" => "event_discount",
            "ticket_levels" => [
              {
                "id" => ticket_level.id,
                "name" => ticket_level.name,
                "deleted" => ticket_level.deleted,
                "order" => ticket_level.order,
                "limit" => ticket_level.limit,
                "object" => "ticket_level",
                "description" => ticket_level.description,
                "amount" => {
                  "cents" => ticket_level.amount,
                  "currency" => "usd"
                },
                "available_to" => "everyone",
                "nonprofit" => nonprofit.id,
                "event" => event.id,
                "event_discounts" => [kind_of(Numeric)]
              }
            ]
          }
        }
      })

      event_discount
    end
  end

  describe "update" do
    it "is without error" do
      event_discount.code = "code"
      event_discount.save
      expect(event_discount.errors).to be_empty
    end

    it "announces updated" do
      expect(Houdini.event_publisher).to receive(:announce).with(:ticket_level_created, anything).ordered
      expect(Houdini.event_publisher).to receive(:announce).with(:event_discount_created, anything).ordered
      expect(Houdini.event_publisher).to receive(:announce).with(:event_discount_updated, {
        "id" => match(/objevt_[a-zA-Z0-9]{22}/),
        "object" => "object_event",
        "type" => "event_discount.updated",
        "data" => {
          "object" => {
            "code" => "code",
            "deleted" => false,
            "discount" => {
              "percent" => percent
            },
            "event" => {
              "id" => event.id,
              "name" => event.name,
              "object" => "event",
              "nonprofit" => nonprofit.id
            },
            "id" => kind_of(Numeric),
            "name" => name,
            "nonprofit" => {
              "id" => nonprofit.id,
              "name" => nonprofit.name,
              "object" => "nonprofit"
            },
            "object" => "event_discount",
            "ticket_levels" => [
              {
                "id" => ticket_level.id,
                "name" => ticket_level.name,
                "deleted" => ticket_level.deleted,
                "order" => ticket_level.order,
                "limit" => ticket_level.limit,
                "object" => "ticket_level",
                "description" => ticket_level.description,
                "amount" => {
                  "cents" => ticket_level.amount,
                  "currency" => "usd"
                },
                "available_to" => "everyone",
                "nonprofit" => nonprofit.id,
                "event" => event.id,
                "event_discounts" => [kind_of(Numeric)]
              }
            ]
          }
        }
      }).ordered

      event_discount.code = "code"
      event_discount.save!
    end
  end

  describe "deleted" do
    it "is without error" do
      event_discount.destroy
      expect(event_discount).to_not be_persisted
    end

    it "announces deleted" do
      expect(Houdini.event_publisher).to receive(:announce).with(:ticket_level_created, anything).ordered
      expect(Houdini.event_publisher).to receive(:announce).with(:event_discount_created, anything).ordered
      expect(Houdini.event_publisher).to receive(:announce).with(:event_discount_deleted, {
        "id" => match(/objevt_[a-zA-Z0-9]{22}/),
        "object" => "object_event",
        "type" => "event_discount.deleted",
        "data" => {
          "object" => {
            "code" => code,
            "deleted" => true,
            "discount" => {
              "percent" => percent
            },
            "event" => {
              "id" => event.id,
              "name" => event.name,
              "object" => "event",
              "nonprofit" => nonprofit.id
            },
            "id" => kind_of(Numeric),
            "name" => name,
            "nonprofit" => {
              "id" => nonprofit.id,
              "name" => nonprofit.name,
              "object" => "nonprofit"
            },
            "object" => "event_discount",
            "ticket_levels" => [
              {
                "id" => ticket_level.id,
                "name" => ticket_level.name,
                "deleted" => ticket_level.deleted,
                "order" => ticket_level.order,
                "limit" => ticket_level.limit,
                "object" => "ticket_level",
                "description" => ticket_level.description,
                "amount" => {
                  "cents" => ticket_level.amount,
                  "currency" => "usd"
                },
                "available_to" => "everyone",
                "nonprofit" => nonprofit.id,
                "event" => event.id,
                "event_discounts" => [kind_of(Numeric)]
              }
            ]
          }
        }
      }).ordered

      event_discount.destroy
    end
  end
end
