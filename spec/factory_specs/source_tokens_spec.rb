# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
describe "nonprofits factory" do
  describe :source_token_base do
    def create_stb
      create(:source_token_base, :with_stripe_card)
    end

    it "is associated with a card record" do
      source = create_stb
      expect(source.tokenizable.stripe_card).to be_a Stripe::Card
    end
  end
end
