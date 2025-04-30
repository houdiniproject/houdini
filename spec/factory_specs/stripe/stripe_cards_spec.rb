# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
describe :stripe_card do
  it "provides a Stripe::Card" do
    card = create(:stripe_card_base)
    expect(card).to be_a Stripe::Card
  end

  it "can be retrieved if requested" do
    card = create(:stripe_card_base)
    server_card = Stripe::Customer.retrieve_source(card.customer, card.id)
    expect(card).to eq server_card
  end

  it "creates 1 Stripe::Customer" do
    create(:stripe_card_base)

    expect(StripeMockHelper.instance.customers.count).to eq 1
  end
end
