# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe DripEmailList, type: :model do
  describe "#list_path" do
    it "is correctly generated" do
      email_list = build_stubbed(:drip_email_list_base)
      expect(email_list.list_path).to eq "lists/" + email_list.mailchimp_list_id
    end
  end

  describe "#list_members_path" do
    it "is correctly generated" do
      email_list = build_stubbed(:drip_email_list_base)
      expect(email_list.list_members_path).to eq "lists/" + email_list.mailchimp_list_id + "/members"
    end
  end
end
