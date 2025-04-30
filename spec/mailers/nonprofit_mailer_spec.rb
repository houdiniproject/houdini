# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe NonprofitMailer, type: :mailer do
  describe "first_charge_email" do
    let(:np) { create(:nonprofit, stripe_account_id: "acct_id") }
    let(:user) { create(:user) }
    let(:role) { create(:role, host: np, user: user, name: :nonprofit_admin) }
    let(:bank_account) { create(:bank_account, nonprofit: np, pending_verification: false) }
    let(:stripe_account) { create(:stripe_account, payouts_enabled: true, stripe_account_id: "acct_id") }

    let(:mail) do
      role
      NonprofitMailer.first_charge_email(np.id)
    end

    let(:mail_with_bank_account) do
      role
      bank_account
      NonprofitMailer.first_charge_email(np.id)
    end

    let(:mail_with_stripe_account) do
      role
      stripe_account
      NonprofitMailer.first_charge_email(np.id)
    end

    describe "no bank account, no stripe account" do
      subject { mail }
      it "recommends to setup bank account" do
        expect(mail.body.encoded).to include "you need to connect your"
      end

      it "recommends to verify stripe" do
        expect(mail.body.encoded).to include "Stripe is requested additional verification"
      end

      it "sets the X-SES-CONFIGURATION-SET" do
        expect(mail["X-SES-CONFIGURATION-SET"].value).to eq "Admin"
      end
    end

    describe "no stripe account" do
      it "does not recommends to setup bank account" do
        expect(mail_with_bank_account.body.encoded).to_not include "you need to connect your"
      end

      it "recommends to verify stripe" do
        expect(mail_with_bank_account.body.encoded).to include "Stripe is requested additional verification"
      end
    end

    describe "no bank account" do
      it "recommends to setup bank account" do
        expect(mail_with_stripe_account.body.encoded).to include "you need to connect your"
      end

      it "does not recommends to verify stripe" do
        expect(mail_with_stripe_account.body.encoded).to_not include "Stripe is requested additional verification"
      end
    end
  end
end
