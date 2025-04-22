# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe Donation, type: :model do
  it {
    is_expected.to have_many(:modern_donations)
  }

  describe "#campaign_gift_purchase?" do
    it "is false without any campaign_gifts" do
      expect(build(:donation)).to_not be_campaign_gift_purchase
    end

    it "is true with campaign_gifts" do
      expect(build(:donation, campaign_gifts: [build(:campaign_gift)])).to be_campaign_gift_purchase
    end
  end

  describe "#actual_donation?" do
    it "is true without any campaign_gifts" do
      expect(build(:donation)).to be_actual_donation
    end

    it "is false with campaign_gifts" do
      expect(build(:donation, campaign_gifts: [build(:campaign_gift)])).to_not be_actual_donation
    end
  end
end
