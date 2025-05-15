# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe Dispute, type: :model do
  it { is_expected.to have_one(:stripe_dispute).with_primary_key(:stripe_dispute_id).with_foreign_key(:stripe_dispute_id) }
  it { is_expected.to belong_to(:charge) }
  it { is_expected.to have_many(:dispute_transactions).order("date ASC") }

  it { is_expected.to have_one(:supporter).through(:charge) }
  it { is_expected.to have_one(:nonprofit).through(:charge) }
  it { is_expected.to have_one(:original_payment).through(:charge).source(:payment) }

  it { is_expected.to have_many(:activities) }

  describe ".charge" do
    include_context :disputes_context
    let!(:charge) {
      force_create(:charge, supporter: supporter,
        stripe_charge_id: "ch_1Y7zzfBCJIIhvMWmSiNWrPAC", nonprofit: nonprofit, payment: force_create(:payment,
          supporter: supporter,
          nonprofit: nonprofit,
          gross_amount: 80000))
    }
    let!(:obj) { force_create(:stripe_dispute, stripe_charge_id: charge.stripe_charge_id) }
    it "directs to a stripe_dispute with the correct Stripe dispute id" do
      expect(dispute.stripe_dispute).to eq obj
    end
  end

  describe ".activities" do
    shared_context :common_specs do
      let(:activity_json) { activity.json_data }
      specify { expect(activity.supporter).to eq supporter }
      specify { expect(activity.nonprofit).to eq nonprofit }
      specify { expect(activity_json["status"]).to eq dispute.status }
      specify { expect(activity_json["reason"]).to eq dispute.reason }
      specify { expect(activity_json["original_id"]).to eq charge.payment.id }
      specify { expect(activity_json["original_kind"]).to eq charge.payment.kind }
      specify { expect(activity_json["original_gross_amount"]).to eq charge.payment.gross_amount }
      specify { expect(activity_json["original_date"]).to eq charge.payment.date }
      specify { expect(activity_json["gross_amount"]).to eq dispute.gross_amount }
    end

    describe "dispute.created" do
      include_context :common_specs
      include_context :dispute_created_context

      let(:obj) { StripeDispute.create(object: json) }
      let(:activity) { dispute.activities.build("DisputeCreated", Time.at(event_json.created)) }

      specify { expect(activity.kind).to eq "DisputeCreated" }
      specify { expect(activity.date).to eq Time.at(event_json.created) }
    end

    describe "dispute.won" do
      include_context :common_specs
      include_context :dispute_won_context

      let(:obj) { StripeDispute.create(object: json) }
      let(:activity) { dispute.activities.build("DisputeWon", Time.at(event_json.created)) }

      specify { expect(activity.kind).to eq "DisputeWon" }
      specify { expect(activity.date).to eq Time.at(event_json.created) }
    end

    describe "dispute.lost" do
      include_context :common_specs
      include_context :dispute_lost_context

      let(:obj) { StripeDispute.create(object: json) }
      let(:activity) { obj.dispute.activities.build("DisputeLost", Time.at(event_json.created)) }

      specify { expect(activity.kind).to eq "DisputeLost" }
      specify { expect(activity_json["gross_amount"]).to eq dispute.gross_amount }
      specify { expect(activity.date).to eq Time.at(event_json.created) }
    end
  end
end
