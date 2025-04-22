# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe UpdateRefunds do
  describe ".disburse_all_with_payments", pending: true do
    it "test" do
      raise
    end
  end

  describe ".reverse_disburse_all_with_payments" do
    let(:payment_to_reverse) { force_create(:payment) }
    let(:payment_to_ignore) { force_create(:payment) }
    let!(:refunds) do
      [
        force_create(:refund, payment: payment_to_reverse, disbursed: true),
        force_create(:refund, payment: payment_to_ignore, disbursed: true)
      ]
    end

    before do
      UpdateRefunds.reverse_disburse_all_with_payments([payment_to_reverse.id])

      refunds.each(&:reload)
    end

    it "reverses refunds as it should" do
      expect(refunds.first.disbursed).to eq false
    end

    it "doesn't reverse unselected refund" do
      expect(refunds.last.disbursed).to eq true
    end
  end
end
