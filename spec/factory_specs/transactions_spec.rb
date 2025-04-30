# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe "transactions factories" do
  describe :transaction_base do
    def create_legacy_donation
      create(:legacy_payment_base, :with_offline_donation).donation
    end

    def create_trx
      legacy_donation = create_legacy_donation
      create(:transaction_base, legacy_donation: legacy_donation, legacy_payments: legacy_donation.payment, supporter: legacy_donation.supporter)
    end

    it "creates one payment" do
      create_trx
      expect(Payment.count).to eq 1
    end

    it "creates one Donation" do
      create_trx
      expect(Donation.count).to eq 1
    end

    it "creates one Nonprofit" do
      create_trx
      expect(Nonprofit.count).to eq 1
    end

    it "creates one Supporter" do
      create_trx
      expect(Supporter.count).to eq 1
    end

    it "creates one OffsitePayment" do
      create_trx
      expect(OffsitePayment.count).to eq 1
    end

    it "creates one TransactionAssignment" do
      create_trx
      expect(TransactionAssignment.count).to eq 1
    end

    it "creates one ModernDonation" do
      create_trx
      expect(ModernDonation.count).to eq 1
    end

    it "creates one Subtransaction" do
      create_trx
      expect(Subtransaction.count).to eq 1
    end

    it "creates one OfflineTransaction" do
      create_trx
      expect(OfflineTransaction.count).to eq 1
    end

    it "creates one SubtransactionPayment" do
      create_trx
      expect(SubtransactionPayment.count).to eq 1
    end

    it "creates one OfflineTransactionCharge" do
      create_trx
      expect(OfflineTransactionCharge.count).to eq 1
    end
  end
end
