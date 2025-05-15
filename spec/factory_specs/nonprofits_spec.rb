# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
describe "nonprofits factory" do
  describe :with_billing_subscription_on_stripe do
    it "creates one Nonprofit" do
      create(:nonprofit_base, :with_billing_subscription_on_stripe)
      expect(Nonprofit.count).to eq 1
    end

    it "creates one BillingSubscription" do
      create(:nonprofit_base, :with_billing_subscription_on_stripe)
      expect(BillingSubscription.count).to eq 1
    end

    it "creates 1 BillingPlan" do
      create(:nonprofit_base, :with_billing_subscription_on_stripe)
      expect(BillingPlan.count).to eq 1
    end

    it "creates 1 Card" do
      create(:nonprofit_base, :with_billing_subscription_on_stripe)
      expect(Card.count).to eq 1
    end
  end
end
