# frozen_string_literal: true

require "rails_helper"

describe InsertSupporter do
  describe ".create_or_update" do
    let(:nonprofit) { create(:nonprofit) }
    let(:supporter_data) {
      {
        "email" => Faker::Internet.email,
        "name" => Faker::FunnyName.name,
        "phone" => Faker::PhoneNumber.cell_phone
      }
    }
    let(:insert_supporter) { InsertSupporter.create_or_update(nonprofit.id, supporter_data) }
    describe "creates an object event" do
      it "of the right type" do
        expect { insert_supporter }.to change { ObjectEvent.where(event_type: "supporter.created").count }.by 1
      end

      it "with the correct information" do
        expect(insert_supporter.object_events.last.object_json).to include_json(
          id: insert_supporter.object_events.last.houid,
          data: {
            object: {
              id: insert_supporter.houid,
              name: supporter_data["name"],
              email: supporter_data["email"],
              phone: supporter_data["phone"],
              object: "supporter",
              legacy_id: insert_supporter.id,
              legacy_nonprofit: nonprofit.id,
              nonprofit: nonprofit.houid
            }
          },
          type: "supporter.created",
          object: "object_event",
          created: insert_supporter.object_events.last.created.to_i
        )
      end
    end
  end
end
