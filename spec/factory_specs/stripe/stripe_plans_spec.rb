# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
describe :stripe_plan do
  it "provides a Stripe::Plan" do
    plan = create(:stripe_plan)
    expect(plan).to be_a Stripe::Plan
  end

  it "can be retrieved if requested" do
    plan = create(:stripe_plan)
    server_plan = Stripe::Plan.retrieve(plan.id)
    expect(plan).to eq server_plan
  end
end
