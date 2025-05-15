# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe SupporterAddress, type: :model do
  it { is_expected.to belong_to(:supporter).required(true).inverse_of(:addresses) }

  describe "#primary?" do
    let(:supporter) { create(:supporter) }
    let(:non_primary_address) { create(:supporter_address, supporter: supporter) }
    let(:primary_address) {
      pa = create(:supporter_address, supporter: supporter)
      supporter.primary_address = pa
      supporter.save!
      pa
    }

    it "is true when supporter has sets as primary" do
      expect(primary_address).to be_primary
    end

    it "is false when supporter hasnt sets as primary" do
      expect(non_primary_address).to_not be_primary
    end
  end
end
