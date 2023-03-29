# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe QueryBillingSubscriptions, :pending => true do

  before(:each) do
    # Qx.delete_from(:billing_plans).where("stripe_plan_id = $id", id: 'stripe_bp').execute
    # Qx.delete_from(:billing_subscriptions).where("nonprofit_id = $id", id: 3624).execute
    # @billing_plan = Qx.insert_into(:billing_plans).values({name: 'test_bp', amount: 0, stripe_plan_id: 'stripe_bp', created_at: Time.current, updated_at: Time.current}).returning('*').execute.last
    # @sub = InsertBillingSubscriptions.trial(3624, @billing_plan['stripe_plan_id'])[:json]
  end

  describe '.plan_tier' do

    it 'gives tier 2 if status=trialing' do
      Qx.update(:billing_subscriptions).set(status: 'trialing').where("id = $id", id: @sub['id']).execute
      expect(QueryBillingSubscriptions.plan_tier(3624)).to eq(2)
    end
    it 'gives tier 0 if status=inactive' do
      Qx.update(:billing_subscriptions).set(status: 'inactive').where("id = $id", id: @sub['id']).execute
      expect(QueryBillingSubscriptions.plan_tier(3624)).to eq(0)
      fail
    end
    it 'gives tier 0 if no subscription' do
      expect(QueryBillingSubscriptions.plan_tier(666)).to eq(0)
      fail
    end
    it 'gives tier 2 if status=active' do
      Qx.update(:billing_subscriptions).set(status: 'active').where("id = $id", id: @sub['id']).execute
      expect(QueryBillingSubscriptions.plan_tier(3624)).to eq(2)
      fail
    end
  end
end
