# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe DisputeTransaction, type: :model do
  it { is_expected.to belong_to(:dispute) }
  it { is_expected.to belong_to(:payment) }

  it { is_expected.to have_one(:nonprofit).through(:dispute) }
  it { is_expected.to have_one(:supporter).through(:dispute) }
  it { is_expected.to have_many(:manual_balance_adjustments) }

  describe "#from_donation?" do
    it "is true when dispute_transaction is associated with a donation" do
      expect(build(:dispute_transaction, :from_donation).from_donation?).to eq true
    end

    it "is true when dispute_transaction is not associated with a donation" do
      expect(build(:dispute_transaction, :not_from_donation).from_donation?).to eq false
    end
  end
end
