# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe UpdateRefunds do
  describe ".disburse_all_with_payments", pending: true do
    it "test" do
      fail
    end
  end

  describe ".reverse_disburse_all_with_payments" do
    let(:payment_to_reverse) { force_create(:payment) }
    let(:payment_to_ignore) { force_create(:payment) }
    let!(:refunds) {
      [
        force_create(:refund, payment: payment_to_reverse, disbursed: true),
        force_create(:refund, payment: payment_to_ignore, disbursed: true)
      ]
    }
    before(:each) {
      UpdateRefunds.reverse_disburse_all_with_payments([payment_to_reverse.id])

      refunds.each { |i| i.reload }
    }

    it "reverses refunds as it should" do
      expect(refunds.first.disbursed).to eq false
    end

    it "doesn't reverse unselected refund" do
      expect(refunds.last.disbursed).to eq true
    end
  end
end
