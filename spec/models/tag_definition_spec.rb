# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe TagDefinition, type: :model do
  include_context :shared_donation_charge_context
  let(:name) { "TAGNAME" }

  let(:tag_definition) { nonprofit.tag_definitions.create(name: name) }
  let(:np_builder_expanded) {
    {
      "id" => nonprofit.id,
      "name" => nonprofit.name,
      "object" => "nonprofit"
    }
  }

  it "creates" do
    expect(tag_definition.errors).to be_empty
  end

  it "announces create" do
    expect(Houdini.event_publisher).to receive(:announce).with(:tag_definition_created, {
      "id" => match(/objevt_[a-zA-Z0-9]{22}/),
      "object" => "object_event",
      "type" => "tag_definition.created",
      "data" => {
        "object" => {
          "id" => kind_of(Numeric),
          "deleted" => false,
          "name" => name,
          "nonprofit" => np_builder_expanded,
          "object" => "tag_definition"
        }
      }
    })

    tag_definition
  end

  it "announces deleted" do
    expect(Houdini.event_publisher).to receive(:announce).with(:tag_definition_created, anything).ordered
    expect(Houdini.event_publisher).to receive(:announce).with(:tag_definition_deleted, {
      "id" => match(/objevt_[a-zA-Z0-9]{22}/),
      "object" => "object_event",
      "type" => "tag_definition.deleted",
      "data" => {
        "object" => {
          "id" => kind_of(Numeric),
          "deleted" => true,
          "name" => name,
          "nonprofit" => np_builder_expanded,
          "object" => "tag_definition"
        }
      }
    }).ordered

    tag_definition.discard!
  end
end
