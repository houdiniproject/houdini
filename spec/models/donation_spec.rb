# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe Donation, type: :model do
  it { is_expected.to belong_to(:supporter) }
  it { is_expected.to belong_to(:card) }
  it { is_expected.to belong_to(:direct_debit_detail) }
  it { is_expected.to belong_to(:profile) }
  it { is_expected.to belong_to(:nonprofit) }
  it { is_expected.to belong_to(:campaign) }
  it { is_expected.to belong_to(:event) }

  it { is_expected.to have_one(:recurring_donation) }
  it { is_expected.to have_one(:payment) }
  it { is_expected.to have_one(:offsite_payment) }
  it { is_expected.to have_one(:tracking) }
  it { is_expected.to have_many(:modern_donations) }
  it { is_expected.to have_many(:charges) }
  it { is_expected.to have_many(:campaign_gifts) }
  it { is_expected.to have_many(:campaign_gift_options).through(:campaign_gifts) }
  it { is_expected.to have_many(:activities) }
  it { is_expected.to have_many(:payments) }

  it { is_expected.to delegate_method(:timezone).to(:nonprofit).with_prefix.allow_nil }

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
