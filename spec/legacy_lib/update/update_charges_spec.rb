# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe UpdateCharges do
  describe ".disburse_all_with_payments", pending: true do
    it "test" do
      raise
    end
  end

  describe ".reverse_disburse_all_with_payments" do
    let(:payment_to_reverse) { force_create(:payment) }
    let(:payment_to_ignore) { force_create(:payment) }
    let(:payment_to_reverse_2) { force_create(:payment) }

    let(:payment_to_reverse_with_refund) { force_create(:payment) }
    let(:reverse_payment_for_refund) { force_create(:payment) }
    let!(:charges) do
      [force_create(:charge, payment: payment_to_reverse, status: "disbursed"),
        force_create(:charge, payment: payment_to_reverse_2, status: "disbursed"),
        force_create(:charge, payment: payment_to_ignore, status: "disbursed"),
        force_create(:charge, payment: payment_to_reverse_with_refund, status: "disbursed")]
    end

    let!(:refunds) { [force_create(:refund, charge: charges.last, payment: reverse_payment_for_refund, disbursed: true)] }

    before do
      UpdateCharges.reverse_disburse_all_with_payments([payment_to_reverse.id, payment_to_reverse_2.id, payment_to_reverse_with_refund.id, reverse_payment_for_refund.id])

      payment_to_reverse.reload
      payment_to_reverse_2.reload
      payment_to_reverse_with_refund.reload
      payment_to_ignore.reload
    end

    it "reverses payments it should" do
      expect(payment_to_reverse.charge.status).to eq "available"
      expect(payment_to_reverse_2.charge.status).to eq "available"
      expect(payment_to_reverse_with_refund.charge.status).to eq "available"
    end

    it "does not reverse other payments" do
      expect(payment_to_ignore.charge.status).to eq "disbursed"
    end
  end
end
