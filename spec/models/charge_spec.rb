# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe Charge, type: :model do
  it { is_expected.to belong_to(:card) }

  it { is_expected.to have_many(:manual_balance_adjustments) }

  describe ".charge" do
    include_context :disputes_context
    let!(:charge) {
      force_create(:charge, supporter: supporter,
        stripe_charge_id: "ch_1Y7zzfBCJIIhvMWmSiNWrPAC", nonprofit: nonprofit, payment: force_create(:payment,
          supporter: supporter,
          nonprofit: nonprofit,
          gross_amount: 80000))
    }
    let(:stripe_dispute) { force_create(:stripe_dispute, stripe_charge_id: charge.stripe_charge_id) }

    it "directs to a stripe_dispute with the correct Stripe charge id" do
      expect(stripe_dispute).to eq charge.stripe_dispute
    end
  end

  describe "#disbursed?" do
    it "is true when status is disbursed" do
      expect(build(:charge, status: "disbursed")).to be_disbursed
    end

    it "is false when status is not disbursed" do
      expect(build(:charge, status: "paid")).to_not be_disbursed
    end
  end
end
