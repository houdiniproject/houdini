# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe QueryBillingSubscriptions, :pending => true do

  before(:each) do
    # Qx.delete_from(:billing_plans).where("stripe_plan_id = $id", id: 'stripe_bp').execute
    # Qx.delete_from(:billing_subscriptions).where("nonprofit_id = $id", id: 3624).execute
    # @billing_plan = Qx.insert_into(:billing_plans).values({name: 'test_bp', amount: 0, stripe_plan_id: 'stripe_bp', created_at: Time.current, updated_at: Time.current}).returning('*').execute.last
    # @sub = InsertBillingSubscriptions.trial(3624, @billing_plan['stripe_plan_id'])[:json]
  end

  describe '.days_left_in_trial' do

    it 'gives days left in trial, rounded down' do
      expect(QueryBillingSubscriptions.days_left_in_trial(3624)).to eq(9)
      fail
    end

    it 'gives 0 if not trialing' do
      Qx.update(:billing_subscriptions).set(status: 'active').where("id = $id", id: @sub['id']).execute
      expect(QueryBillingSubscriptions.days_left_in_trial(3624)).to eq(0)
      fail
    end
    
    it 'gives negative if past expiration' do
      Qx.update(:billing_subscriptions).set(status: 'trialing', created_at: 20.days.ago).where("id = $id", id: @sub['id']).execute
      expect(QueryBillingSubscriptions.days_left_in_trial(3624)).to eq(-11)
      fail
    end
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

  describe '.currently_in_trial?' do

    it 'gives true if status=trialing' do
      Qx.update(:billing_subscriptions).set(status: 'trialing').where("id = $id", id: @sub['id']).execute
      expect(QueryBillingSubscriptions.currently_in_trial?(3624)).to eq(true)
      fail
    end

    it 'gives false if status!=trialing' do
      Qx.update(:billing_subscriptions).set(status: 'active').where("id = $id", id: @sub['id']).execute
      expect(QueryBillingSubscriptions.currently_in_trial?(3624)).to eq(false)
      fail
    end

    it 'gives false if no subscription' do
      expect(QueryBillingSubscriptions.currently_in_trial?(666)).to be_falsey
      fail
    end
  end
end
