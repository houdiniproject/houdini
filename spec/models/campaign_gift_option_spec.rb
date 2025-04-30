# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe CampaignGiftOption, type: :model do
  it { is_expected.to belong_to(:campaign).required(true) }
  it { is_expected.to have_many(:campaign_gifts) }
  it { is_expected.to have_many(:donations).through(:campaign_gifts) }
  it { is_expected.to have_one(:nonprofit).through(:campaign) }

  it { is_expected.to validate_presence_of(:name) }

  describe "#gifts_available?" do
    it "when quantity nil" do
      expect(build(:campaign_gift_option_base, quantity: nil)).to be_gifts_available
    end

    it "when quantity zero" do
      expect(build(:campaign_gift_option_base, quantity: 0)).to be_gifts_available
    end

    it "when saved associated campaign gifts is less than quantity" do
      expect(build(:campaign_gift_option_base, quantity: 1)).to be_gifts_available
    end

    it "but not when saved campaign gifts is equal to quantity" do
      expect(build(:campaign_gift_option_base, :with_one_campaign_gift, quantity: 1)).to be_gifts_available
    end

    it "but not when saved campaign gifts is more than quantity" do
      expect(build(:campaign_gift_option_base, :with_two_campaign_gifts, quantity: 1)).to be_gifts_available
    end
  end
end
