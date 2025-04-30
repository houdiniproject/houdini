# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
describe :stripe_subscription do
  it "creates a plan if none provided" do
    subscription = create(:stripe_subscription)
    expect { Stripe::Plan.retrieve(subscription.plan.id) }.to_not raise_error
  end

  it "creates a customer if none provided" do
    subscription = create(:stripe_subscription)
    expect { Stripe::Customer.retrieve(subscription.customer) }.to_not raise_error
  end

  it "uses a custom plan if provided" do
    provided_plan = create(:stripe_plan_base)
    subscription = create(:stripe_subscription, stripe_plan: provided_plan)
    expect(subscription.plan).to eq provided_plan
  end

  it "uses a custom customer if provided" do
    provided_customer = create(:stripe_customer_base)
    subscription = create(:stripe_subscription, stripe_customer: provided_customer)
    expect(subscription.customer).to eq provided_customer.id
  end
end
