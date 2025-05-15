# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
describe :stripe_customer do
  it "provides a Stripe::Customer" do
    customer = create(:stripe_customer_base)
    expect(customer).to be_a Stripe::Customer
  end

  it "can be retrieved if requested" do
    customer = create(:stripe_customer_base)
    server_customer = Stripe::Customer.retrieve(customer.id)
    expect(customer).to eq server_customer
  end
end
