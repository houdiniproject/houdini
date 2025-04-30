# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
describe "nonprofits factory" do
  describe :with_billing_subscription_on_stripe do
    it {
      nonprofit = create(:nonprofit_base, :with_billing_subscription_on_stripe)
      expect(nonprofit).to have_attributes(attributes_for(:nonprofit_base, :with_billing_subscription_on_stripe))
    }
  end
end
