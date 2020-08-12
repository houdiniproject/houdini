# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe StripeDispute, :type => :model do
  before(:each) do
    StripeMock.start
  end

  describe "dispute.created" do
    let(:json) do
      event =StripeMock.mock_webhook_event('charge.dispute.created')
      event['data']['object']
    end

    let(:obj) { StripeDispute.create(object:json) }

    it 'has status of needs_response' do 
      expect(obj.status).to eq 'needs_response'
    end

    it 'has reason of duplicate' do 
      expect(obj.reason).to eq 'duplicate'
    end

    it 'has 0 balance transactions' do 
      expect(obj.balance_transactions.count).to eq 0
    end

    it 'has a net_change of 0' do
      expect(obj.net_change).to eq 0
    end

    it 'has an amount of 80000' do
      expect(obj.amount).to eq 80000
    end

    it 'has a correct charge id ' do 
      expect(obj.stripe_charge_id).to eq "ch_1Y7zzfBCJIIhvMWmSiNWrPAC"
    end

    it 'has a correct dispute id' do 
      expect(obj.stripe_dispute_id).to eq "du_1Y7pRWBCJIIhvMWmv0ZPR9Ef"
    end
  end

  describe "dispute.funds_withdrawn" do
    let(:json) do
      event =StripeMock.mock_webhook_event('charge.dispute.funds_withdrawn')
      event['data']['object']
    end

    let(:obj) { StripeDispute.create(object:json) }

    it 'has status of needs_response' do 
      expect(obj.status).to eq 'needs_response'
    end

    it 'has reason of duplicate' do 
      expect(obj.reason).to eq 'duplicate'
    end

    it 'has 1 balance transactions' do 
      expect(obj.balance_transactions.count).to eq 1
    end

    it 'has a net_change of -81500' do
      expect(obj.net_change).to eq -81500
    end

    it 'has an amount of 80000' do
      expect(obj.amount).to eq 80000
    end

    it 'has a correct charge id ' do 
      expect(obj.stripe_charge_id).to eq "ch_1Y7zzfBCJIIhvMWmSiNWrPAC"
    end

    it 'has a correct dispute id' do 
      expect(obj.stripe_dispute_id).to eq "du_1Y7pRWBCJIIhvMWmv0ZPR9Ef"
    end
  end

  describe "dispute.funds_reinstated" do
    let(:json) do
      event =StripeMock.mock_webhook_event('charge.dispute.funds_reinstated')
      event['data']['object']
    end

    let(:obj) { StripeDispute.create(object:json) }

    it 'has status of under_review' do 
      expect(obj.status).to eq 'under_review'
    end

    it 'has reason of credit_not_processed' do 
      expect(obj.reason).to eq 'credit_not_processed'
    end

    it 'has 0 balance transactions' do 
      expect(obj.balance_transactions.count).to eq 2
    end

    it 'has a net_change of 0' do
      expect(obj.net_change).to eq 0
    end

    it 'has an amount of 22500' do
      expect(obj.amount).to eq 22500
    end

    it 'has a correct charge id ' do 
      expect(obj.stripe_charge_id).to eq "ch_1Y7vFYBCJIIhvMWmsdRJWSw5"
    end

    it 'has a correct dispute id' do 
      expect(obj.stripe_dispute_id).to eq "dp_1Y75JUBCJIIhvMWmSRi5eQbU"
    end
  end

  describe "dispute.closed, status = lost" do
    let(:json) do
      event =StripeMock.mock_webhook_event('charge.dispute.closed-lost')
      event['data']['object']
    end

    let(:obj) { StripeDispute.create(object:json) }

    it 'has status of under_review' do 
      expect(obj.status).to eq 'lost'
    end

    it 'has reason of credit_not_processed' do 
      expect(obj.reason).to eq 'duplicate'
    end

    it 'has 1 balance transactions' do 
      expect(obj.balance_transactions.count).to eq 1
    end

    it 'has a net_change of -81500' do
      expect(obj.net_change).to eq -81500
    end

    it 'has an amount of 80000' do
      expect(obj.amount).to eq 80000
    end

    it 'has a correct charge id' do 
      expect(obj.stripe_charge_id).to eq "ch_1Y7zzfBCJIIhvMWmSiNWrPAC"
    end

    it 'has a correct dispute id' do 
      expect(obj.stripe_dispute_id).to eq "du_1Y7pRWBCJIIhvMWmv0ZPR9Ef"
    end
  end

  describe "dispute.closed, status = won" do
    let(:json) do
      event =StripeMock.mock_webhook_event('charge.dispute.closed-won')
      event['data']['object']
    end

    let(:obj) { StripeDispute.create(object:json) }

    it 'has status of under_review' do 
      expect(obj.status).to eq 'won'
    end

    it 'has reason of credit_not_processed' do 
      expect(obj.reason).to eq 'credit_not_processed'
    end

    it 'has 2 balance transactions' do 
      expect(obj.balance_transactions.count).to eq 2
    end

    it 'has a net_change of 0' do
      expect(obj.net_change).to eq 0
    end

    it 'has an amount of 22500' do
      expect(obj.amount).to eq 22500
    end

    it 'has a correct charge id ' do 
      expect(obj.stripe_charge_id).to eq "ch_1Y7vFYBCJIIhvMWmsdRJWSw5"
    end

    it 'has a correct dispute id' do 
      expect(obj.stripe_dispute_id).to eq "dp_1Y75JUBCJIIhvMWmSRi5eQbU"
    end
  end

  describe '.dispute' do
    let!(:dispute){ force_create(:dispute)}
    let(:stripe_dispute) { create(:stripe_dispute)}
    it 'directs to a dispute with the correct Stripe dispute id' do
      expect(stripe_dispute.dispute).to eq dispute
    end
  end

  describe '.charge' do
    let!(:charge){ force_create(:charge)}
    let(:stripe_dispute) { create(:stripe_dispute)}
    it 'directs to a dispute with the correct Stripe charge id' do
      expect(stripe_dispute.charge).to eq charge
    end
  end
end
