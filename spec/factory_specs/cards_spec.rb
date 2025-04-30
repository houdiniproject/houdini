# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
describe "cards factory" do
  describe :cards_base do
    context :with_created_stripe_customer_and_card do
      it {
        card = create(:card_base, :with_created_stripe_customer_and_card)
        expect(card.stripe_card).to_not be_nil
      }

      it {
        card = create(:card_base, :with_created_stripe_customer_and_card)
        expect(card.stripe_customer).to_not be_nil
      }
    end
  end
end
