require "rails_helper"

RSpec.describe ObjectEvent, type: :model do
  it_behaves_like "an houidable entity", :evt

  around(:each) { |ex|
    Timecop.freeze(Time.new(2020, 5, 4)) do
      ex.run
    end
  }
  let(:simple_object_with_parent) { create(:simple_object_with_parent) }

  let(:evt) {
    simple_object_with_parent.publish_created
  }

  describe "after_save is accurate" do
    subject(:event) { evt }
    it {
      is_expected.to be_persisted
    }

    it {
      is_expected.to have_attributes(
        houid: match_houid("evt"),
        event_type: "simple_object.created",
        event_entity: simple_object_with_parent,
        created: Time.new(2020, 5, 4)
      )
    }

    describe "json" do
      subject(:json) { event.object_json }
      it {
        is_expected.to include(
          "id" => match_houid("evt"),
          "type" => "simple_object.created",
          "object" => "object_event",
          "created" => Time.new(2020, 5, 4).to_i
        )
      }

      describe "-> data" do
        subject(:data) { json["data"] }
        describe "-> object" do
          subject(:object) { data["object"] }

          it {
            is_expected.to include(
              "id" => simple_object_with_parent.houid,
              "object" => "simple_object",
              "friends" => all(be_an(Integer)),
              "parent" => be_a(Hash)
            )
          }
        end
      end
    end
  end
end
