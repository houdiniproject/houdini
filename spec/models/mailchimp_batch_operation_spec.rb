# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe MailchimpBatchOperation, type: :model do
  context "when supporter.email is empty" do
    describe "#to_h" do
      it "returns nil" do
        supporter = build_stubbed(:supporter_base)
        email_list = build_stubbed(:email_list_base)
        operation = MailchimpBatchOperation.new(supporter: supporter, list: email_list, method: "DELETE")
        expect(operation.to_h).to be_nil
      end
    end
  end
  context "when method == DELETE" do
    describe "#to_h" do
      it "has no body key" do
        supporter = build_stubbed(:supporter_base, email: "something@email.com")
        email_list = build_stubbed(:email_list_base)
        operation = MailchimpBatchOperation.new(supporter: supporter, list: email_list, method: "DELETE")

        expect(operation.to_h).to eq({method: "DELETE", path: email_list.list_members_path + "/#{Digest::MD5.hexdigest(supporter.email.downcase)}"})
      end
    end
  end

  context "when method == POST" do
    describe "#to_h" do
      it "has a body key" do
        supporter = build_stubbed(:supporter_base, email: "something@email.com")
        email_list = build_stubbed(:email_list_base)
        operation = MailchimpBatchOperation.new(supporter: supporter, list: email_list, method: "POST")

        expect(operation.to_h).to match({method: "POST", path: email_list.list_members_path, body: an_instance_of(String)})
      end
    end
  end
end
