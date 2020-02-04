require "rails_helper"

RSpec.describe StripeAccountMailer, :type => :mailer do
  describe "more_info_needed" do
    let(:mail) { StripeAccountMailer.more_info_needed }

    it "renders the headers" do
      expect(mail.subject).to eq("More info needed")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "verified" do
    let(:mail) { StripeAccountMailer.verified }

    it "renders the headers" do
      expect(mail.subject).to eq("Verified")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

  describe "not_completed" do
    let(:mail) { StripeAccountMailer.not_completed }

    it "renders the headers" do
      expect(mail.subject).to eq("Not completed")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
