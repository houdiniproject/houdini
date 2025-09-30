# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe Charge, type: :model do
  it { is_expected.to belong_to(:card) }
  it { is_expected.to belong_to(:supporter) }
  it { is_expected.to belong_to(:direct_debit_detail) }
  it { is_expected.to belong_to(:nonprofit) }
  it { is_expected.to belong_to(:donation) }
  it { is_expected.to belong_to(:payment) }

  it { is_expected.to have_one(:campaign).through(:donation) }
  it { is_expected.to have_one(:recurring_donation).through(:donation) }
  it do
    is_expected.to have_one(:stripe_dispute).with_primary_key(:stripe_charge_id)
                                            .with_foreign_key(:stripe_charge_id)
  end
  it { is_expected.to have_many(:tickets) }
  it { is_expected.to have_many(:events).through(:tickets) }
  it { is_expected.to have_many(:refunds) }
  it { is_expected.to have_many(:disputes) }
  it do
    is_expected.to belong_to(:stripe_charge_object).with_primary_key(:stripe_charge_id)
                                                   .with_foreign_key(:stripe_charge_id)
                                                   .class_name("StripeCharge")
  end
  it { is_expected.to have_many(:manual_balance_adjustments) }

  it { is_expected.to delegate_method(:timezone).to(:nonprofit).with_prefix.allow_nil }

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
