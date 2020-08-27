# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe StripeDispute, :type => :model do
  describe "dispute.created" do
    include_context :dispute_created_specs
    
    let(:obj) { StripeDispute.create(object:json) }
  end

  describe "dispute.funds_withdrawn" do
    include_context :dispute_funds_withdrawn_specs
    let(:obj) { StripeDispute.create(object:json) }
  end

  describe "dispute.created AND funds_withdrawn at same time" do 
    include_context :dispute_created_and_withdrawn_at_same_time_specs
    let(:obj) do 
      sd = StripeDispute.create(object:json_created)
      sd.object = json_funds_withdrawn
      sd.save!
      sd
    end
  end

  describe "dispute.created AND funds_withdrawn in order" do 
    include_context :dispute_created_and_withdrawn_in_order_specs
    let(:obj) do 
      sd = StripeDispute.create(object:json_created)
      sd.object = json_funds_withdrawn
      sd.save!
      sd
    end
  end

  describe "dispute.funds_reinstated" do
    include_context :dispute_funds_reinstated_specs
    let(:obj) { StripeDispute.create(object:json) }    
  end

  describe "dispute.closed, status = lost" do
    include_context :dispute_lost_specs

    let(:obj) { StripeDispute.create(object:json) }
  end

  describe "dispute.created -> dispute.funds_withdrawn -> dispute.closed, status = lost " do
    include_context :dispute_created_withdrawn_and_lost_in_order_specs

    let(:obj) do
      obj = StripeDispute.create(object:json_created); 
      obj.object = json_funds_withdrawn;
      obj.save!
      obj.object = json_lost;
      obj.save!
      obj
    end
  end

  describe "dispute.created-with-one-withdrawn -> dispute.funds_withdrawn -> dispute.closed, status = lost " do
    include_context :dispute_created_with_withdrawn_and_lost_in_order_specs

    let(:obj) do
      obj = StripeDispute.create(object:json_created); 
      obj.object = json_funds_withdrawn;
      obj.save!
      obj.object = json_lost;
      obj.save!
      obj
    end
  end

  # describe "dispute.closed, status = lost -> dispute.created -> dispute.funds_withdrawn" do
  #   let(:created_json) do
  #     event =StripeMock.mock_webhook_event('charge.dispute.created')
  #     event['data']['object']
  #   end
  #   let(:withdrawn_json) do
  #     event =StripeMock.mock_webhook_event('charge.dispute.funds_withdrawn')
  #     event['data']['object']
  #   end
  #   let(:lost_json) do
  #     event =StripeMock.mock_webhook_event('charge.dispute.closed-lost')
  #     event['data']['object']
  #   end
  #   let(:supporter) { force_create(:supporter)}
  #   let!(:charge) { force_create(:charge, supporter: supporter, stripe_charge_id: 'ch_1Y7zzfBCJIIhvMWmSiNWrPAC', nonprofit: supporter.nonprofit)}

  #   let(:obj) { 
  #     obj = StripeDispute.create(object:lost_json); 
  #     obj.object = created_json;
  #     obj.save!
  #     obj.object = withdrawn_json;
  #     obj.save!
  #     obj
  #   }

  #   let(:dispute) { obj.dispute }
  #   let(:dispute_transactions) { dispute.dispute_transactions }
  #   let(:withdrawal_transaction) {dispute.dispute_transactions.order("date").first}
  #   let(:withdrawal_payment) {withdrawal_transaction.payment}
  #   let(:reinstated_transaction) {dispute.dispute_transactions.order("date").second}
  #   let(:reinstated_payment) {reinstated_transaction.payment}

  #   it 'has status of under_review' do 
  #     expect(obj.status).to eq 'lost'
  #   end

  #   it 'has reason of credit_not_processed' do 
  #     expect(obj.reason).to eq 'duplicate'
  #   end

  #   it 'has 1 balance transactions' do 
  #     expect(obj.balance_transactions.count).to eq 1
  #   end

  #   it 'has a net_change of -81500' do
  #     expect(obj.net_change).to eq -81500
  #   end

  #   it 'has an amount of 80000' do
  #     expect(obj.amount).to eq 80000
  #   end

  #   it 'has a correct charge id' do 
  #     expect(obj.stripe_charge_id).to eq "ch_1Y7zzfBCJIIhvMWmSiNWrPAC"
  #   end

  #   it 'has a correct dispute id' do 
  #     expect(obj.stripe_dispute_id).to eq "dp_05RsQX2eZvKYlo2C0FRTGSSA"
  #   end

  #   describe "dispute" do
  #     subject { dispute }
  #     specify { expect(subject).to be_persisted }
  #     specify { expect(subject.gross_amount).to eq 80000 }
  #     specify { expect(subject.status).to eq "lost" }
  #     specify { expect(subject.reason).to eq 'duplicate' }
  #   end

  #   it 'has 1 dispute transactions' do
  #     expect(dispute_transactions.count).to eq 1
  #   end

  #   describe 'has a withdrawal_transaction' do
  #     subject{ withdrawal_transaction }
  #     specify { expect(subject).to be_persisted }
  #     specify { expect(subject.gross_amount).to eq -80000 }
  #     specify { expect(subject.fee_total).to eq -1500 }
  #     specify { expect(subject.stripe_transaction_id).to eq 'txn_1Y7pdnBCJIIhvMWmJ9KQVpfB' }
  #     specify { expect(subject.date).to eq DateTime.new(2020, 8, 3, 4, 55, 55)}
  #     specify { expect(subject.disbursed).to eq false }
  #   end

  #   describe 'has a withdrawal_payment' do
  #     subject { withdrawal_payment}
  #     specify { expect(subject).to be_persisted }
  #     specify { expect(subject.gross_amount).to eq -80000}
  #     specify { expect(subject.fee_total).to eq -1500}
  #     specify { expect(subject.kind).to eq 'Dispute'}
  #     specify { expect(subject.nonprofit).to eq supporter.nonprofit}
  #     specify { expect(subject.date).to eq DateTime.new(2020, 8, 3, 4, 55, 55)}
  #   end

  #   it 'has no reinstated transaction' do 
  #     expect(reinstated_transaction).to be_nil
  #   end
  # end

  describe "dispute.closed, status = won" do
    include_context :dispute_won_specs
    let(:obj) { StripeDispute.create(object:json) }
  end

  describe "two disputes on the same transaction" do
    describe 'partial1' do
      include_context :dispute_with_two_partial_disputes_withdrawn_at_same_time_spec__partial1
      let(:obj) do
        partial1 = StripeDispute.create(object:json_partial1);
        partial2 = StripeDispute.create(object:json_partial2);
        partial1
      end
    end

    describe 'partial2' do
      include_context :dispute_with_two_partial_disputes_withdrawn_at_same_time_spec__partial2
      let(:obj) do
        partial1 = StripeDispute.create(object:json_partial1);
        partial2 = StripeDispute.create(object:json_partial2);
        partial2
      end
    end
  end

  describe "legacy dispute specs" do
    include_context :legacy_dispute_specs
    let(:obj) do
      StripeDispute.create(object:json)
    end
  end
end
