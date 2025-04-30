# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe DonationMailer, type: :mailer do
  describe "donor_recurring_donation_change_amount" do
    let(:np) { force_create(:nonprofit, name: "nonprofit", email: "blah") }
    let(:s) { force_create(:supporter, email: "supporter.email@mail.teha") }
    let(:oldcard) { force_create(:card) }
    let(:donation) { create(:donation, nonprofit_id: np.id, supporter_id: s.id, card_id: oldcard.id, amount: 999) }
    let(:default_message) { "You have successfully changed your recurring donation amount. Please see the receipt and details below." }

    let(:rd) {
      create(:recurring_donation, amount: 999, active: true, supporter_id: s.id, donation_id: donation.id, nonprofit_id: np.id, start_date: Date.today, interval: 1, time_unit: "month")
    }

    before(:each) {
      np
      s
      oldcard
      donation
      default_message
    }
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
        expect(mail.body.encoded).to match "#{custom_message}"
        expect(mail.body.encoded).to_not match "#{default_message}"
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
        expect(mail.body.encoded).to match "#{default_message}"
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
        expect(mail.body.encoded).to match "#{default_message}"
      end
    end
  end

  describe "donor_payment_notification" do
    let(:thank_you_note_default) { "thank you Supporter" }
    let(:thank_you_note_named) { "thank you Penelope" }
    let(:campaign_custom_default) { "Supporter" }
    let(:campaign_custom_named) { "Penelope" }
    let(:np) { force_create(:nonprofit, name: "nonprofit", email: "blah", thank_you_note: "thank you {{FIRSTNAME}}") }
    let(:s) { force_create(:supporter, email: "supporter.email@mail.teha", name: "") }
    let(:s_with_name) { force_create(:supporter, email: "supporter.email@mail.teha", name: "Penelope") }
    let(:oldcard) { force_create(:card) }
    let(:charge) { force_create(:charge, payment_id: payment.id, supporter_id: s.id, amount: 999) }
    let(:payment) { force_create(:payment, donation_id: donation.id, supporter_id: s.id, gross_amount: 999) }
    let(:donation) { force_create(:donation, nonprofit_id: np.id, supporter_id: s.id, card_id: oldcard.id, amount: 999) }

    let(:charge_with_campaign) { force_create(:charge, payment_id: payment_with_campaign.id, supporter_id: s.id, amount: 999) }
    let(:payment_with_campaign) { force_create(:payment, donation_id: donation_with_campaign.id, supporter_id: s.id, gross_amount: 999) }
    let(:donation_with_campaign) { force_create(:donation, nonprofit_id: np.id, supporter_id: s.id, card_id: oldcard.id, amount: 999, campaign_id: campaign.id) }

    let(:charge_with_custom_campaign_message) { force_create(:charge, payment_id: payment_with_custom_campaign_message.id, supporter_id: s.id, amount: 999) }
    let(:payment_with_custom_campaign_message) { force_create(:payment, donation_id: donation_with_custom_campaign_message.id, supporter_id: s.id, gross_amount: 999) }
    let(:donation_with_custom_campaign_message) { force_create(:donation, nonprofit_id: np.id, supporter_id: s.id, card_id: oldcard.id, amount: 999, campaign_id: campaign_with_custom_message.id) }

    let(:charge_with_invalid_custom_campaign_message) { force_create(:charge, payment_id: payment_with_invalid_custom_campaign_message.id, supporter_id: s.id, amount: 999) }
    let(:payment_with_invalid_custom_campaign_message) { force_create(:payment, donation_id: donation_with_invalid_custom_campaign_message.id, supporter_id: s.id, gross_amount: 999) }
    let(:donation_with_invalid_custom_campaign_message) { force_create(:donation, nonprofit_id: np.id, supporter_id: s.id, card_id: oldcard.id, amount: 999, campaign_id: campaign_with_invalid_custom_message.id) }

    let(:charge_named) { force_create(:charge, payment_id: payment_named.id, supporter_id: s_with_name.id, amount: 999) }
    let(:payment_named) { force_create(:payment, donation_id: donation_named.id, supporter_id: s_with_name.id, gross_amount: 999) }
    let(:donation_named) { force_create(:donation, nonprofit_id: np.id, supporter_id: s_with_name.id, card_id: oldcard.id, amount: 999) }
    let(:charge_with_campaign_named) { force_create(:charge, payment_id: payment_with_campaign_named.id, supporter_id: s_with_name.id, amount: 999) }
    let(:payment_with_campaign_named) { force_create(:payment, donation_id: donation_with_campaign_named.id, supporter_id: s_with_name.id, gross_amount: 999) }
    let(:donation_with_campaign_named) { force_create(:donation, nonprofit_id: np.id, supporter_id: s_with_name.id, card_id: oldcard.id, amount: 999, campaign_id: campaign.id) }
    let(:charge_with_custom_campaign_message_named) { force_create(:charge, payment_id: payment_with_custom_campaign_message_named.id, supporter_id: s_with_name.id, amount: 999) }
    let(:payment_with_custom_campaign_message_named) { force_create(:payment, donation_id: donation_with_custom_campaign_message_named.id, supporter_id: s_with_name.id, gross_amount: 999) }
    let(:donation_with_custom_campaign_message_named) { force_create(:donation, nonprofit_id: np.id, supporter_id: s_with_name.id, card_id: oldcard.id, amount: 999, campaign_id: campaign_with_custom_message.id) }

    let(:charge_with_invalid_custom_campaign_message_named) { force_create(:charge, payment_id: payment_with_invalid_custom_campaign_message_named.id, supporter_id: s_with_name.id, amount: 999) }
    let(:payment_with_invalid_custom_campaign_message_named) { force_create(:payment, donation_id: donation_with_invalid_custom_campaign_message_named.id, supporter_id: s_with_name.id, gross_amount: 999) }
    let(:donation_with_invalid_custom_campaign_message_named) { force_create(:donation, nonprofit_id: np.id, supporter_id: s_with_name.id, card_id: oldcard.id, amount: 999, campaign_id: campaign_with_invalid_custom_message.id) }

    let(:campaign) { force_create(:campaign, nonprofit_id: np.id) }
    let(:campaign_with_custom_message) { force_create(:campaign, nonprofit_id: np.id, receipt_message: "{{FIRSTNAME}}") }
    let(:campaign_with_invalid_custom_message) { force_create(:campaign, nonprofit_id: np.id, receipt_message: "<html></html>") }

    describe "no name supporter" do
      describe "no campaign" do
        let(:mail) { DonationMailer.donor_payment_notification(donation.id, payment.id) }
        it "contains default thank you note" do
          expect(mail.body.encoded).to include thank_you_note_default
        end
      end

      describe "campaign" do
        let(:mail) { DonationMailer.donor_payment_notification(donation_with_campaign.id, payment_with_campaign.id) }
        it "contains default thank you note" do
          expect(mail.body.encoded).to include thank_you_note_default
        end
      end

      describe "campaign_with_custom" do
        let(:mail) { DonationMailer.donor_payment_notification(donation_with_custom_campaign_message.id, payment_with_custom_campaign_message.id) }
        it "contains default campaign" do
          expect(mail.body.encoded).to include campaign_custom_default
        end
      end

      describe "campaign with invalid custom" do
        let(:mail) { DonationMailer.donor_payment_notification(donation_with_invalid_custom_campaign_message.id, payment_with_invalid_custom_campaign_message.id) }
        it "contains default thank you note" do
          expect(mail.body.encoded).to include thank_you_note_default
        end
      end
    end

    describe "named supporter" do
      describe "no campaign" do
        let(:mail) { DonationMailer.donor_payment_notification(donation_named.id, payment_named.id) }
        it "contains named thank you note" do
          expect(mail.body.encoded).to include thank_you_note_named
        end
      end

      describe "campaign" do
        let(:mail) { DonationMailer.donor_payment_notification(donation_with_campaign_named.id, payment_with_campaign_named.id) }
        it "contains named thank you note" do
          expect(mail.body.encoded).to include thank_you_note_named
        end
      end

      describe "campaign_with_custom" do
        let(:mail) { DonationMailer.donor_payment_notification(donation_with_custom_campaign_message_named.id, payment_with_custom_campaign_message_named.id) }
        it "contains named campaign" do
          expect(mail.body.encoded).to include campaign_custom_named
        end
      end

      describe "campaign with invalid custom" do
        let(:mail) { DonationMailer.donor_payment_notification(donation_with_invalid_custom_campaign_message_named.id, payment_with_invalid_custom_campaign_message_named.id) }
        it "contains named thank you note" do
          expect(mail.body.encoded).to include thank_you_note_named
        end
      end
    end

    describe "specific recurring donation payment" do
      let(:recurring_donation) do
        force_create(:recurring_donation, donation_id: donation.id, supporter_id: s.id, nonprofit_id: np.id, amount: 999)

        payment_to_send_receipt_for
        other_payment
      end

      let(:donation) { force_create(:donation, nonprofit_id: np.id, supporter_id: s.id, card_id: oldcard.id, amount: 999) }

      let(:payment_to_send_receipt_for) { force_create(:payment, supporter_id: s.id, amount: 999, donation_id: donation.id, date: Time.at(2020, 5, 1)) }
      let(:other) { force_create(:payment, supporter_id: s.id, amount: 999, donation_id: donation.id, date: Time.at(2020, 5, 1)) }
    end
  end

  describe "#nonprofit_payment_notification" do
    context "when supporter name is set" do
      before(:each) {
        expect(QueryUsers).to receive(:nonprofit_user_emails).and_return(["anything@example.com"])
      }

      let(:supporter) { create(:supporter_base) }
      let(:donation) { create(:donation_base, supporter: supporter, nonprofit: supporter.nonprofit) }
      let(:payment) { create(:payment_base, donation: donation) }

      let!(:mail) {
        DonationMailer.nonprofit_payment_notification(
          donation.id,
          payment.id
        )
      }

      it "uses the supporter name in subject" do
        expect(mail.subject).to include supporter.name
      end
    end

    context "when supporter name is nil" do
      before(:each) {
        expect(QueryUsers).to receive(:nonprofit_user_emails).and_return(["anything@example.com"])
      }

      let(:supporter) { create(:supporter_base, email: "supporter@example.com", name: nil) }
      let(:donation) { create(:donation_base, supporter: supporter, nonprofit: supporter.nonprofit) }
      let(:payment) { create(:payment_base, donation: donation) }

      let!(:mail) {
        DonationMailer.nonprofit_payment_notification(
          donation.id,
          payment.id
        )
      }

      it "uses the supporter email instead of name in subject" do
        expect(mail.subject).to include supporter.email
      end
    end

    context "when supporter name is blank", pending: true do
      before(:each) {
        expect(QueryUsers).to receive(:nonprofit_user_emails).and_return(["anything@example.com"])
      }

      let(:supporter) { create(:supporter_base, email: "supporter@example.com", name: "") }
      let(:donation) { create(:donation_base, supporter: supporter, nonprofit: supporter.nonprofit) }
      let(:payment) { create(:payment_base, donation: donation) }

      let!(:mail) {
        DonationMailer.nonprofit_payment_notification(
          donation.id,
          payment.id
        )
      }

      it "uses the supporter email instead of name in subject" do
        expect(mail.subject).to include supporter.email
      end
    end

    context "when dedication is not set" do
      before(:each) {
        expect(QueryUsers).to receive(:nonprofit_user_emails).and_return(["anything@example.com"])
      }

      let(:supporter) { create(:supporter_base) }
      let(:donation) { create(:donation_base, supporter: supporter, nonprofit: supporter.nonprofit) }
      let(:payment) { create(:payment_base, donation: donation) }

      let!(:mail) {
        DonationMailer.nonprofit_payment_notification(
          donation.id,
          payment.id
        )
      }

      it "does not include the dedication section" do
        expect(mail.body.encoded).to_not include "Acknowledgement Phone"
      end
    end

    context "when dedication is blank" do
      before(:each) {
        expect(QueryUsers).to receive(:nonprofit_user_emails).and_return(["anything@example.com"])
      }

      let(:supporter) { create(:supporter_base) }
      let(:donation) { create(:donation_base, supporter: supporter, nonprofit: supporter.nonprofit, dedication: "") }
      let(:payment) { create(:payment_base, donation: donation) }

      let!(:mail) {
        DonationMailer.nonprofit_payment_notification(
          donation.id,
          payment.id
        )
      }

      it "does not include the dedication section" do
        expect(mail.body.encoded).to_not include "Acknowledgement Phone"
      end
    end

    context "when dedication is set" do
      before(:each) {
        expect(QueryUsers).to receive(:nonprofit_user_emails).and_return(["anything@example.com"])
      }

      let(:supporter) { create(:supporter_base) }
      let(:donation) { create(:donation_with_dedication, supporter: supporter, nonprofit: supporter.nonprofit) }
      let(:payment) { create(:payment_base, donation: donation) }

      let!(:mail) {
        DonationMailer.nonprofit_payment_notification(
          donation.id,
          payment.id
        )
      }

      it "does not include the dedication section" do
        expect(mail.body.encoded).to include "Acknowledgement Phone"
        expect(mail.body.encoded).to include "234-343-3234"
      end
    end
  end
end
