# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"
# rubocop:disable RSpec/MessageSpies
# rubocop:disable RSpec/ExampleLength
# rubocop:disable RSpec/MultipleExpectations
RSpec.describe SupporterNote do
  include_context :shared_donation_charge_context
  let(:content) { "CONTENT" }
  let(:content2) { "CONTENT2" }

  let(:supporter_note) { supporter.supporter_notes.create(content: content, user: user) }

  it "creates" do
    expect(supporter_note.errors).to be_empty
  end

  it "announces created" do
    expect(Houdini.event_publisher).to receive(:announce).with(:supporter_created, anything)
    expect(Houdini.event_publisher).to receive(:announce).with(:supporter_address_created, anything)
    expect(Houdini.event_publisher).to receive(:announce).with(
      :supporter_note_created,
      {
        "id" => match_houid("objevt"),
        "object" => "object_event",
        "type" => "supporter_note.created",
        "data" => {
          "object" => {
            "id" => kind_of(Numeric),
            "deleted" => false,
            "content" => content,
            "nonprofit" => {
              "id" => nonprofit.id,
              "name" => nonprofit.name,
              "object" => "nonprofit"
            },
            "object" => "supporter_note",
            "user" => {
              "id" => user.id,
              "object" => "user"
            },
            "supporter" => supporter_to_builder_base.merge({"name" => "Fake Supporter Name"})
          }
        }
      }
    )

    supporter_note
  end

  it "announces updated" do
    expect(Houdini.event_publisher).to receive(:announce).with(:supporter_created, anything)
    expect(Houdini.event_publisher).to receive(:announce).with(:supporter_address_created, anything)
    expect(Houdini.event_publisher).to receive(:announce).with(:supporter_note_created, anything).ordered
    expect(Houdini.event_publisher).to receive(:announce).with(
      :supporter_note_updated,
      {
        "id" => match_houid("objevt"),
        "object" => "object_event",
        "type" => "supporter_note.updated",
        "data" => {
          "object" => {
            "id" => kind_of(Numeric),
            "deleted" => false,
            "content" => content2,
            "nonprofit" => {
              "id" => nonprofit.id,
              "name" => nonprofit.name,
              "object" => "nonprofit"
            },
            "object" => "supporter_note",
            "user" => {
              "id" => user.id,
              "object" => "user"
            },
            "supporter" => supporter_to_builder_base.merge({"name" => "Fake Supporter Name"})
          }
        }
      }
    ).ordered

    supporter_note
    supporter_note.content = content2
    supporter_note.save!
  end

  it "announces deleted" do
    allow(Houdini.event_publisher)
    expect(Houdini.event_publisher).to receive(:announce).with(:supporter_created, anything)
    expect(Houdini.event_publisher).to receive(:announce).with(:supporter_address_created, anything)
    expect(Houdini.event_publisher).to receive(:announce).with(:supporter_note_created, anything).ordered
    expect(Houdini.event_publisher).to receive(:announce).with(
      :supporter_note_deleted,
      {
        "id" => match_houid("objevt"),
        "object" => "object_event",
        "type" => "supporter_note.deleted",
        "data" => {
          "object" => {
            "id" => kind_of(Numeric),
            "deleted" => true,
            "content" => content,
            "nonprofit" => {
              "id" => nonprofit.id,
              "name" => nonprofit.name,
              "object" => "nonprofit"
            },
            "object" => "supporter_note",
            "user" => {
              "id" => user.id,
              "object" => "user"
            },
            "supporter" => supporter_to_builder_base.merge({"name" => "Fake Supporter Name"})
          }
        }
      }
    ).ordered

    supporter_note.discard!
  end
end

# rubocop:enable all
