# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe ChargeCard do
  include_context "Stripe::Source doubles"

  describe ".of" do
    subject { described_class.of(charge) }

    context "for a charge with a source" do
      let(:charge) { Stripe::Charge.construct_from({id: "ch_1", source: visa_card}) }

      it { is_expected.to eq visa_card }
    end

    context "for a PaymentIntent charge paid with a card" do
      let(:charge) {
        Stripe::Charge.construct_from({id: "ch_1", source: nil, payment_method_details: {type: "card", card: {brand: "amex", country: "UK"}}})
      }

      it { is_expected.to have_attributes(brand: "American Express", country: "UK") }
    end

    context "for a PaymentIntent charge paid with Apple Pay" do
      let(:charge) {
        Stripe::Charge.construct_from({id: "ch_1", source: nil, payment_method_details: {type: "card", card: {brand: "mastercard", country: "US", wallet: {type: "apple_pay"}}}})
      }

      it { is_expected.to have_attributes(brand: "MasterCard", country: "US") }
    end

    context "for a card brand without a known name" do
      let(:charge) {
        Stripe::Charge.construct_from({id: "ch_1", source: nil, payment_method_details: {type: "card", card: {brand: "eftpos_au", country: "AU"}}})
      }

      it { is_expected.to have_attributes(brand: "eftpos_au", country: "AU") }
    end

    context "for a PaymentIntent charge not paid with a card" do
      let(:charge) {
        Stripe::Charge.construct_from({id: "ch_1", source: nil, payment_method_details: {type: "us_bank_account", us_bank_account: {}}})
      }

      it { expect { subject }.to raise_error(ArgumentError, /ch_1/) }
    end
  end
end
