# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe AdminMailer, type: :mailer do
  describe "notify_failed_gift" do
    around(:each) do |ex|
      StripeMockHelper.mock do
        ex.run
      end
    end
    let!(:np) { force_create(:nonprofit, name: "nonprofit", email: "blah", timezone: "UTC") }
    let!(:s) { force_create(:supporter, email: "supporter.email@mail.teha") }
    let!(:oldcard) { force_create(:card) }
    let!(:payment) { force_create(:payment, donation_id: donation.id, nonprofit_id: np.id, supporter_id: s.id, gross_amount: 999) }
    let!(:donation) { force_create(:donation, nonprofit_id: np.id, supporter_id: s.id, card_id: oldcard.id, amount: 999) }
    let!(:charge) { create(:charge, donation: donation, nonprofit: np, amount: 100, created_at: Time.now) }
    let(:campaign) { force_create(:campaign, nonprofit: np) }
    let!(:campaign_gift_option_with_desc) { force_create(:campaign_gift_option, description: "desc", amount_one_time: "", campaign: campaign) }
    let!(:campaign_gift_option) { force_create(:campaign_gift_option, campaign: campaign) }
    let(:mail) { AdminMailer.notify_failed_gift(donation, payment, campaign_gift_option) }
    let(:mail_with_desc) { AdminMailer.notify_failed_gift(donation, payment, campaign_gift_option_with_desc) }

    it "renders the headers for mail without desc" do
      expect(mail.subject).to eq("Tried to associate donation #{donation.id} with campaign gift option #{campaign_gift_option.id} which is out of stock")
      expect(mail.to).to eq(["support@commitchange.com"])
      expect(mail.from).to eq(["support@commitchange.com"])
    end

    it "renders the body without desc" do
      expect(mail.body.encoded).to_not include("<td>desc</td>")
    end

    it "renders the headers on mail with desc" do
      expect(mail_with_desc.subject).to eq("Tried to associate donation #{donation.id} with campaign gift option #{campaign_gift_option_with_desc.id} which is out of stock")
      expect(mail_with_desc.to).to eq(["support@commitchange.com"])
      expect(mail_with_desc.from).to eq(["support@commitchange.com"])
    end

    it "renders the body with desc" do
      expect(mail.body.encoded).to include("<td>Description:</td>")
    end
  end
end
