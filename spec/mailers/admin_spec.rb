# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe AdminMailer, type: :mailer do
  describe "notify_failed_gift" do
    around do |ex|
      before_value = Houdini.hoster.support_email
      Houdini.hoster.support_email = "expected_support@supportemail.com"
      ex.run
      Houdini.hoster.support_email = before_value
    end

    let!(:np) { force_create(:nm_justice, name: "nonprofit", email: "blah", timezone: "UTC") }
    let!(:s) { force_create(:supporter, email: "supporter.email@mail.teha") }
    let!(:oldcard) { force_create(:card) }
    let!(:donation) { force_create(:donation, nonprofit_id: np.id, supporter_id: s.id, card_id: oldcard.id, amount: 999) }
    let!(:charge) { create(:charge, donation: donation, nonprofit: np, amount: 100, created_at: Time.now) }
    let(:campaign) { force_create(:campaign, nonprofit: np) }
    let!(:campaign_gift_option_with_desc) { force_create(:campaign_gift_option, description: "desc", amount_one_time: 999, campaign: campaign) }
    let!(:campaign_gift_option) { force_create(:campaign_gift_option, campaign: campaign) }
    let(:mail) { AdminMailer.notify_failed_gift(donation, campaign_gift_option) }
    let(:mail_with_desc) { AdminMailer.notify_failed_gift(donation, campaign_gift_option_with_desc) }

    it "renders the headers for mail without desc" do
      expect(mail.subject).to eq("Tried to associate donation #{donation.id} with campaign gift option #{campaign_gift_option.id} which is out of stock")
      expect(mail.to).to eq(["expected_support@supportemail.com"])
      expect(mail.from).to eq(["expected_support@supportemail.com"])
    end

    it "renders the body without desc" do
      expect(mail.body.encoded).to_not include("<td>desc</td>")
    end

    it "renders the headers on mail with desc" do
      expect(mail_with_desc.subject).to eq("Tried to associate donation #{donation.id} with campaign gift option #{campaign_gift_option_with_desc.id} which is out of stock")
      expect(mail_with_desc.to).to eq(["expected_support@supportemail.com"])
      expect(mail_with_desc.from).to eq(["expected_support@supportemail.com"])
    end

    it "renders the body with desc" do
      expect(mail.body.encoded).to include("<td>Description:</td>")
    end
  end
end
