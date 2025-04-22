# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

RSpec.describe StripeAccountMailer, type: :mailer do
  describe "no_longer_verified" do
    let(:np) { create(:nonprofit, timezone: "America/Chicago") }
    let(:user) { create(:user) }
    let(:role) { create(:role, host: np, user: user, name: :nonprofit_admin) }
    let(:deadline) { Time.new(2020, 2, 3, 22, 32, 12) }
    let(:deadline_string) { "February 3, 2020 at 4:32:12 PM" }
    let(:generic_deadline_substring) { "advised to complete this" }

    let(:mail) do
      role
      StripeAccountMailer.no_longer_verified(np, deadline)
    end

    let(:mail_no_deadline) do
      role
      StripeAccountMailer.no_longer_verified(np, nil)
    end

    it "includes correct deadline string" do
      expect(mail.body.encoded).to include(deadline_string)
    end

    it "includes generic deadline string" do
      expect(mail_no_deadline.body.encoded).to include(generic_deadline_substring)
    end
  end

  describe "not_completed" do
    let(:np) { create(:nonprofit, timezone: "America/Chicago") }
    let(:user) { create(:user) }
    let(:role) { create(:role, host: np, user: user, name: :nonprofit_admin) }
    let(:deadline) { Time.new(2020, 2, 3, 22, 32, 12) }
    let(:deadline_string) { "February 3, 2020 at 4:32:12 PM" }
    let(:generic_deadline_substring) { "advised to complete this" }

    let(:mail) do
      role
      StripeAccountMailer.not_completed(np, deadline)
    end

    let(:mail_no_deadline) do
      role
      StripeAccountMailer.not_completed(np, nil)
    end

    it "includes correct deadline string" do
      expect(mail.body.encoded).to include(deadline_string)
    end

    it "includes generic deadline string" do
      expect(mail_no_deadline.body.encoded).to include(generic_deadline_substring)
    end
  end

  describe "more_info_needed" do
    let(:np) { create(:nonprofit, timezone: "America/Chicago") }
    let(:user) { create(:user) }
    let(:role) { create(:role, host: np, user: user, name: :nonprofit_admin) }
    let(:deadline) { Time.new(2020, 2, 3, 22, 32, 12) }
    let(:deadline_string) { "February 3, 2020 at 4:32:12 PM" }
    let(:generic_deadline_substring) { "advised to complete this" }

    let(:mail) do
      role
      StripeAccountMailer.more_info_needed(np, deadline)
    end

    let(:mail_no_deadline) do
      role
      StripeAccountMailer.more_info_needed(np, nil)
    end

    it "includes correct deadline string" do
      expect(mail.body.encoded).to include(deadline_string)
    end

    it "includes generic deadline string" do
      expect(mail_no_deadline.body.encoded).to include(generic_deadline_substring)
    end
  end
end
