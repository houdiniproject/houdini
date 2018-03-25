require 'rails_helper'

describe InsertBillingSubscriptions, :skip => true do

  let(:sub) do
    # billing_plan = Qx.insert_into(:billing_plans).values({name: 'test_bp', amount: 0, stripe_plan_id: 'stripe_bp', created_at: Time.current, updated_at: Time.current}).returning('*').execute.last
    # InsertBillingSubscriptions.trial(3624, billing_plan['stripe_plan_id'])[:json]
  end

  describe '.trial' do
    it 'creates the record' do
      sub
      expect(sub["id"]).to be_present
    end
  end

  describe '.check_trial' do

    it 'marks as inactive after 10 days' do
      sub
      Timecop.freeze(10.days.from_now){ InsertBillingSubscriptions.check_trial(sub['id']) }
      updated = Qx.fetch(:billing_subscriptions, sub['id']).last
      expect(updated['status']).to eq('inactive')
    end

    it 'does not change the status if not still trialing after 10 days' do
      sub
      Qx.update(:billing_subscriptions).set(status: 'active').where("id = $id", id: sub['id']).execute
      Timecop.freeze(10.days.from_now){ InsertBillingSubscriptions.check_trial(sub['id']) }
      updated = Qx.fetch(:billing_subscriptions, sub['id']).last
      expect(updated['status']).to eq('active')
    end
  end
end
