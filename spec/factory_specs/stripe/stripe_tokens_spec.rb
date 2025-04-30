# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
describe :stripe_token do
  it "provides a Stripe::Token" do
    token = create(:stripe_token)
    expect(token).to be_a Stripe::Token
  end

  it "can be retrieved if requested" do
    token = create(:stripe_token)
    server_token = Stripe::Token.retrieve(token.id)
    expect(token).to eq server_token
  end
end
