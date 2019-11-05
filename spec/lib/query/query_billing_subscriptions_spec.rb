# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'
require 'insert/insert_billing_subscriptions'
require 'query/query_billing_subscriptions'

describe QueryBillingSubscriptions, pending: true do
  before(:each) do
  end

  describe '.plan_tier' do
    it 'gives tier 0 if status=inactive' do
      Qx.update(:billing_subscriptions).set(status: 'inactive').where('id = $id', id: @sub['id']).execute
      expect(QueryBillingSubscriptions.plan_tier(3624)).to eq(0)
      raise
    end
    it 'gives tier 0 if no subscription' do
      expect(QueryBillingSubscriptions.plan_tier(666)).to eq(0)
      raise
    end
    it 'gives tier 2 if status=active' do
      Qx.update(:billing_subscriptions).set(status: 'active').where('id = $id', id: @sub['id']).execute
      expect(QueryBillingSubscriptions.plan_tier(3624)).to eq(2)
      raise
    end
  end
end
