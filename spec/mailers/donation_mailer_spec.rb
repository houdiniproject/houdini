# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe DonationMailer, type: :mailer do
  describe "donor_recurring_donation_change_amount" do
    let(:np) { force_create(:nm_justice, name: "nonprofit", email: "blah") }
    let(:s) { force_create(:supporter, email: "supporter.email@mail.teha") }
    let(:oldcard) { force_create(:card) }
    let(:donation) { create(:donation, nonprofit_id: np.id, supporter_id: s.id, card_id: oldcard.id, amount: 999) }
    let(:default_message) { "You have successfully changed your recurring donation amount. Please see the receipt and details below." }

    let(:rd) do
      create(:recurring_donation, amount: 999, active: true, supporter_id: s.id, donation_id: donation.id, nonprofit_id: np.id, start_date: Date.today, interval: 1, time_unit: "month")
    end

    before do
      np
      s
      oldcard
      donation
      default_message
    end

    describe "with custom" do
      let(:custom_message) { "custom_message" }
      let!(:custom_donor_amount) { create(:miscellaneous_np_info, change_amount_message: custom_message, nonprofit: np) }

      let!(:mail) { DonationMailer.donor_recurring_donation_change_amount(rd.id, 1000) }

      it "renders the headers" do
        expect(mail.subject).to eq("Recurring donation amount changed for #{np.name}")
        expect(mail.to).to eq(["supporter.email@mail.teha"])
        expect(mail.reply_to).to eq([np.email])
      end

      it "renders the body" do
        expect(mail.body.encoded).to match custom_message.to_s
        expect(mail.body.encoded).to_not match default_message.to_s
      end
    end

    describe "without custom message" do
      let!(:custom_donor_amount) { create(:miscellaneous_np_info, nonprofit: np) }

      let!(:mail) { DonationMailer.donor_recurring_donation_change_amount(rd.id, 1000) }

      it "renders the headers" do
        expect(mail.subject).to eq("Recurring donation amount changed for #{np.name}")
        expect(mail.to).to eq(["supporter.email@mail.teha"])
        expect(mail.reply_to).to eq([np.email])
      end

      it "renders the body" do
        expect(mail.body.encoded).to match default_message.to_s
      end
    end

    describe "without miscinfo" do
      let!(:mail) { DonationMailer.donor_recurring_donation_change_amount(rd.id, 1000) }

      it "renders the headers" do
        expect(mail.subject).to eq("Recurring donation amount changed for #{np.name}")
        expect(mail.to).to eq(["supporter.email@mail.teha"])
        expect(mail.reply_to).to eq([np.email])
      end

      it "renders the body" do
        expect(mail.body.encoded).to match default_message.to_s
      end
    end
  end
end
