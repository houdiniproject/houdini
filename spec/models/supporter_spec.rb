# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe Supporter, type: :model do
  include_context :shared_donation_charge_context
  let(:supporter_name) { "CUSTOM SSUPPORTER" }
  let(:merged_into_supporter_name) { "I've been merged into!" }
  let(:address) { "address for supporter" }
  let(:supporter) { nonprofit.supporters.create(name: supporter_name, address: address) }
  let(:merged_supporter) { nonprofit.supporters.create(name: supporter_name, address: address, merged_into: merged_into_supporter, deleted: true) }
  let(:merged_into_supporter) { nonprofit.supporters.create(name: merged_into_supporter_name, address: address) }

  describe "supporter" do
    it "created" do
      supporter_result = supporter_to_builder_base.merge({
        "supporter_addresses" => [
          supporter_address_to_builder_base
        ],
        "nonprofit" => nonprofit_to_builder_base
      })

      expect(Houdini.event_publisher).to receive(:announce).with(:supporter_created, {
        "id" => match(/objevt_[a-zA-Z0-9]{22}/),
        "object" => "object_event",
        "type" => "supporter.created",
        "data" => {
          "object" => supporter_result
        }
      }).ordered

      expect(Houdini.event_publisher).to receive(:announce).with(:supporter_address_created, anything).ordered

      supporter
    end

    it "deletes" do
      expect(Houdini.event_publisher).to receive(:announce).with(:supporter_created, anything).ordered
      expect(Houdini.event_publisher).to receive(:announce).with(:supporter_address_created, anything).ordered
      expect(Houdini.event_publisher).to_not receive(:announce).with(:supporter_updated)
      expect(Houdini.event_publisher).to_not receive(:announce).with(:supporter_address_updated)

      supporter_result = supporter_to_builder_base.merge({
        "deleted" => true,
        "supporter_addresses" => [
          supporter_address_to_builder_base.merge({"deleted" => true})
        ],
        "nonprofit" => nonprofit_to_builder_base
      })

      expect(Houdini.event_publisher).to receive(:announce).with(:supporter_deleted, {
        "id" => match(/objevt_[a-zA-Z0-9]{22}/),
        "object" => "object_event",
        "type" => "supporter.deleted",
        "data" => {
          "object" => supporter_result
        }
      }).ordered

      expect(Houdini.event_publisher).to receive(:announce).with(:supporter_address_deleted, anything).ordered

      supporter.discard!
    end
  end

  describe "supporter_address events" do
    it "creates" do
      expect(Houdini.event_publisher).to receive(:announce).with(:supporter_created, anything).ordered
      expect(Houdini.event_publisher).to receive(:announce).with(:supporter_address_created, {
        "id" => match(/objevt_[a-zA-Z0-9]{22}/),
        "object" => "object_event",
        "type" => "supporter_address.created",
        "data" => {
          "object" => supporter_address_to_builder_base.merge({
            "supporter" => supporter_to_builder_base,
            "nonprofit" => nonprofit_to_builder_base
          })
        }
      }).ordered

      supporter
    end

    it "deletes" do
      expect(Houdini.event_publisher).to receive(:announce).with(:supporter_created, anything).ordered
      expect(Houdini.event_publisher).to receive(:announce).with(:supporter_address_created, anything).ordered
      expect(Houdini.event_publisher).to_not receive(:announce).with(:supporter_updated)
      expect(Houdini.event_publisher).to_not receive(:announce).with(:supporter_address_updated)

      expect(Houdini.event_publisher).to receive(:announce).with(:supporter_deleted, anything)

      supporter_address_result = supporter_address_to_builder_base.merge({
        "deleted" => true,
        "supporter" => supporter_to_builder_base.merge({"deleted" => true}),
        "nonprofit" => nonprofit_to_builder_base
      })

      expect(Houdini.event_publisher).to receive(:announce).with(:supporter_address_deleted, {
        "id" => match(/objevt_[a-zA-Z0-9]{22}/),
        "object" => "object_event",
        "type" => "supporter_address.deleted",
        "data" => {
          "object" => supporter_address_result
        }
      }).ordered

      supporter.discard!
    end
  end

  describe "supporter and supporter_address events update events are separate" do
    it "only fires supporter on supporter only change" do
      expect(Houdini.event_publisher).to receive(:announce).with(:supporter_created, anything).ordered
      expect(Houdini.event_publisher).to receive(:announce).with(:supporter_address_created, anything).ordered

      expect(Houdini.event_publisher).to receive(:announce).with(:supporter_updated, {
        "id" => match(/objevt_[a-zA-Z0-9]{22}/),
        "object" => "object_event",
        "type" => "supporter.updated",
        "data" => {
          "object" => supporter_to_builder_base.merge({
            "name" => merged_into_supporter_name,
            "supporter_addresses" => [
              supporter_address_to_builder_base
            ],
            "nonprofit" => nonprofit_to_builder_base
          })

        }
      }).ordered
      expect(Houdini.event_publisher).to_not receive(:announce).with(:supporter_address_updated, anything)

      supporter.update(name: merged_into_supporter_name)
    end

    it "only fires supporter_address on supporter_address only change" do
      expect(Houdini.event_publisher).to receive(:announce).with(:supporter_created, anything).ordered
      expect(Houdini.event_publisher).to receive(:announce).with(:supporter_address_created, anything).ordered

      expect(Houdini.event_publisher).to receive(:announce).with(:supporter_address_updated, {
        "id" => match(/objevt_[a-zA-Z0-9]{22}/),
        "object" => "object_event",
        "type" => "supporter_address.updated",
        "data" => {
          "object" => supporter_address_to_builder_base.merge({
            "city" => "new_city",
            "supporter" => supporter_to_builder_base,
            "nonprofit" => nonprofit_to_builder_base
          })
        }
      }).ordered

      # expect(Houdini.event_publisher).to_not receive(:announce).with(:supporter_updated, anything)

      supporter.update(city: "new_city")
    end
  end
end
