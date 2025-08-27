# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe Event, type: :model do
  it { is_expected.to have_many(:ticketholders).through(:tickets).source(:supporter) }
  it { is_expected.to define_enum_for(:in_person_or_virtual).with_values(in_person: "in_person", virtual: "virtual").backed_by_column_of_type(:string).validating }

  describe "#virtual_or_valid_address" do
    it { is_expected.to validate_presence_of(:address) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:state_code) }

    context "when #virtual is true" do
      subject { Event.new(in_person_or_virtual: "virtual") }
      it { is_expected.to_not validate_presence_of(:address) }
      it { is_expected.to_not validate_presence_of(:city) }
      it { is_expected.to_not validate_presence_of(:state_code) }
    end
  end
end
