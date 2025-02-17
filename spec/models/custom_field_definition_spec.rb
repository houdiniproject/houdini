# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe CustomFieldDefinition, type: :model do
  include_context :shared_donation_charge_context
  let(:name) { "CustomFieldDefinition1" }

  let(:custom_field_definition) { nonprofit.custom_field_definitions.create(name: name) }
  let(:np_builder_expanded) {
    {
      "id" => nonprofit.id,
      "name" => nonprofit.name,
      "object" => "nonprofit"
    }
  }

  it "creates" do
    expect(custom_field_definition.errors).to be_empty
  end

  it "announces create" do
    expect(Houdini.event_publisher).to receive(:announce).with(:custom_field_definition_created, {
      "id" => match_houid("objevt"),
      "object" => "object_event",
      "type" => "custom_field_definition.created",
      "data" => {
        "object" => {
          "id" => kind_of(Numeric),
          "deleted" => false,
          "name" => name,
          "nonprofit" => np_builder_expanded,
          "object" => "custom_field_definition"
        }
      }
    })

    custom_field_definition
  end

  it "announces deleted" do
    expect(Houdini.event_publisher).to receive(:announce).with(:custom_field_definition_created, anything).ordered
    expect(Houdini.event_publisher).to receive(:announce).with(:custom_field_definition_deleted, {
      "id" => match_houid("objevt"),
      "object" => "object_event",
      "type" => "custom_field_definition.deleted",
      "data" => {
        "object" => {
          "id" => kind_of(Numeric),
          "deleted" => true,
          "name" => name,
          "nonprofit" => np_builder_expanded,
          "object" => "custom_field_definition"
        }
      }
    }).ordered

    custom_field_definition.discard!
  end
end
