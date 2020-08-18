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
    let(:supporter) { force_create(:supporter)}
    let!(:charge) { force_create(:charge, supporter: supporter, stripe_charge_id: 'ch_1Y7zzfBCJIIhvMWmSiNWrPAC')}

    let(:obj) { StripeDispute.create(object:json) }
    let(:dispute) { obj.dispute }
    let(:dispute_transactions) { dispute.dispute_transactions }


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

    it 'has a saved dispute' do 
      expect(dispute).to be_persisted
    end

    it 'has a dispute with 80000' do 
      expect(dispute.gross_amount).to eq 80000
    end

    it 'has a dispute with status of needs_response' do 
      expect(dispute.status).to eq "needs_response"
    end

    it 'has a dispute with reason of duplicate' do 
      expect(dispute.reason).to eq 'duplicate'
    end

    it 'has no dispute transactions' do 
      expect(dispute_transactions).to eq []
    end
  end

  describe "dispute.funds_withdrawn" do
    let(:json) do
      event =StripeMock.mock_webhook_event('charge.dispute.funds_withdrawn')
      event['data']['object']
    end
    let(:supporter) { force_create(:supporter)}
    let!(:charge) { force_create(:charge, supporter: supporter, stripe_charge_id: 'ch_1Y7zzfBCJIIhvMWmSiNWrPAC', nonprofit: supporter.nonprofit)}

    let(:obj) { StripeDispute.create(object:json) }

    let(:dispute) { obj.dispute }
    let(:dispute_transactions) { dispute.dispute_transactions }
    let(:withdrawal_transaction) {dispute.dispute_transactions.first}
    let(:withdrawal_payment) {withdrawal_transaction.payment}

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

    it 'has a correct charge id ' do 
      expect(obj.stripe_charge_id).to eq "ch_1Y7zzfBCJIIhvMWmSiNWrPAC"
    end

    describe "dispute" do
      subject { dispute }
      specify {expect(subject).to be_persisted }
      specify {expect(subject.gross_amount).to eq 80000 }
      specify {expect(subject.status).to eq "needs_response" }
      specify { expect(subject.reason).to eq 'duplicate' }
    end

    it 'has one dispute transaction' do
      expect(dispute_transactions.count).to eq 1
    end

    describe 'has a withdrawal_transaction' do
      subject{ withdrawal_transaction }
      specify {  expect(subject).to be_persisted }
      specify {  expect(subject.gross_amount).to eq -80000 }
      specify {  expect(subject.fee_total).to eq -1500 }
      specify {  expect(subject.stripe_transaction_id).to eq 'txn_1Y7pdnBCJIIhvMWmJ9KQVpfB' }
      specify {  expect(subject).to be_persisted }
      specify { expect(subject.disbursed).to eq false }
    end

    describe 'has a withdrawal_payment' do
      subject { withdrawal_payment}
      specify { expect(subject).to be_persisted }
      specify { expect(subject.gross_amount).to eq -80000}
      specify { expect(subject.fee_total).to eq -1500}
      specify { expect(subject.kind).to eq 'Dispute'}
      specify { expect(subject.nonprofit).to eq supporter.nonprofit}
      specify { expect(subject.date).to eq DateTime.new(2020, 8, 3, 4, 55, 55)}
    end
  end

  describe "dispute.created AND funds_withdrawn at sametime" do 
    let(:json_created) do
      event =StripeMock.mock_webhook_event('charge.dispute.created-with-one-withdrawn')
      event['data']['object']
    end

    let(:json_funds_withdrawn) do
      event =StripeMock.mock_webhook_event('charge.dispute.funds_withdrawn')
      event['data']['object']
    end

    let(:supporter) { force_create(:supporter)}
    let!(:charge) { force_create(:charge, supporter: supporter, stripe_charge_id: 'ch_1Y7zzfBCJIIhvMWmSiNWrPAC', nonprofit: supporter.nonprofit)}

    let(:obj) { sd =StripeDispute.create(object:json_created); sd.object = json_funds_withdrawn; sd.save!; sd}

    let(:dispute) { obj.dispute }
    let(:dispute_transactions) { dispute.dispute_transactions }
    let(:withdrawal_transaction) {dispute.dispute_transactions.first}
    let(:withdrawal_payment) {withdrawal_transaction.payment}

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

    it 'has a correct charge id ' do 
      expect(obj.stripe_charge_id).to eq "ch_1Y7zzfBCJIIhvMWmSiNWrPAC"
    end

    describe "dispute" do
      subject { dispute }
      specify {expect(subject).to be_persisted }
      specify {expect(subject.gross_amount).to eq 80000 }
      specify {expect(subject.status).to eq "needs_response" }
      specify { expect(subject.reason).to eq 'duplicate' }
    end

    it 'has one dispute transaction' do
      expect(dispute_transactions.count).to eq 1
    end

    describe 'has a withdrawal_transaction' do
      subject{ withdrawal_transaction }
      specify {  expect(subject).to be_persisted }
      specify {  expect(subject.gross_amount).to eq -80000 }
      specify {  expect(subject.fee_total).to eq -1500 }
      specify {  expect(subject.stripe_transaction_id).to eq 'txn_1Y7pdnBCJIIhvMWmJ9KQVpfB' }
      specify {  expect(subject).to be_persisted }
      specify { expect(subject.disbursed).to eq false }
    end

    describe 'has a withdrawal_payment' do
      subject { withdrawal_payment}
      specify { expect(subject).to be_persisted }
      specify { expect(subject.gross_amount).to eq -80000}
      specify { expect(subject.fee_total).to eq -1500}
      specify { expect(subject.kind).to eq 'Dispute'}
      specify { expect(subject.nonprofit).to eq supporter.nonprofit}
      specify { expect(subject.date).to eq DateTime.new(2020, 8, 3, 4, 55, 55)}
    end

    it 'has only added one payment' do
      obj
      expect(Payment.count).to eq 1
    end

    it 'has only one dispute transaction' do 
      obj
      expect(DisputeTransaction.count).to eq 1
    end

  end

  describe "dispute.funds_reinstated" do
    let(:json) do
      event =StripeMock.mock_webhook_event('charge.dispute.funds_reinstated')
      event['data']['object']
    end

    let(:obj) { StripeDispute.create(object:json) }

    let(:supporter) { force_create(:supporter)}
    let!(:charge) { force_create(:charge, supporter: supporter, stripe_charge_id: 'ch_1Y7vFYBCJIIhvMWmsdRJWSw5', nonprofit: supporter.nonprofit)}

    let(:obj) { StripeDispute.create(object:json) }

    let(:dispute) { obj.dispute }
    let(:dispute_transactions) { dispute.dispute_transactions }
    let(:withdrawal_transaction) {dispute.dispute_transactions.order("date").first}
    let(:withdrawal_payment) {withdrawal_transaction.payment}
    let(:reinstated_transaction) {dispute.dispute_transactions.order("date").second}
    let(:reinstated_payment) {reinstated_transaction.payment}
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

    describe "dispute" do
      subject { dispute }
      specify { expect(subject).to be_persisted }
      specify { expect(subject.gross_amount).to eq 22500 }
      specify { expect(subject.status).to eq "under_review" }
      specify { expect(subject.reason).to eq 'credit_not_processed' }
    end

    it 'has two dispute transactions' do
      expect(dispute_transactions.count).to eq 2
    end

    describe 'has a withdrawal_transaction' do
      subject{ withdrawal_transaction }
      specify {  expect(subject).to be_persisted }
      specify {  expect(subject.gross_amount).to eq -22500 }
      specify {  expect(subject.fee_total).to eq -1500 }
      specify {  expect(subject.stripe_transaction_id).to eq 'txn_1Y75JVBCJIIhvMWmsnGK1JLD' }
      specify { expect(subject.date).to eq DateTime.new(2019,9,4,13,29,20)}
      specify { expect(subject.disbursed).to eq false }
    end

    describe 'has a withdrawal_payment' do
      subject { withdrawal_payment}
      specify { expect(subject).to be_persisted }
      specify { expect(subject.gross_amount).to eq -22500}
      specify { expect(subject.fee_total).to eq -1500}
      specify { expect(subject.kind).to eq 'Dispute'}
      specify { expect(subject.nonprofit).to eq supporter.nonprofit}
      specify { expect(subject.date).to eq DateTime.new(2019,9,4,13,29,20)}
    end


    describe 'has a reinstated_transaction' do
      subject{ reinstated_transaction }
      specify {  expect(subject).to be_persisted }
      specify {  expect(subject.gross_amount).to eq 22500 }
      specify {  expect(subject.fee_total).to eq 1500 }
      specify {  expect(subject.stripe_transaction_id).to eq 'txn_1Y71X0BCJIIhvMWmMmtTY4m1' }
      specify { expect(subject.date).to eq DateTime.new(2019,11,28,21,43,10)}
      specify { expect(subject.disbursed).to eq false }
    end

    describe 'has a reinstated_payment' do
      subject { reinstated_payment}
      specify { expect(subject).to be_persisted }
      specify { expect(subject.gross_amount).to eq 22500}
      specify { expect(subject.fee_total).to eq 1500}
      specify { expect(subject.kind).to eq 'DisputeReversed'}
      specify { expect(subject.nonprofit).to eq supporter.nonprofit}
      specify { expect(subject.date).to eq DateTime.new(2019,11,28,21,43,10)}
    end
  end

  describe "dispute.closed, status = lost" do
    let(:json) do
      event =StripeMock.mock_webhook_event('charge.dispute.closed-lost')
      event['data']['object']
    end
    let(:supporter) { force_create(:supporter)}
    let!(:charge) { force_create(:charge, supporter: supporter, stripe_charge_id: 'ch_1Y7zzfBCJIIhvMWmSiNWrPAC', nonprofit: supporter.nonprofit)}

    let(:obj) { StripeDispute.create(object:json) }

    let(:dispute) { obj.dispute }
    let(:dispute_transactions) { dispute.dispute_transactions }
    let(:withdrawal_transaction) {dispute.dispute_transactions.order("date").first}
    let(:withdrawal_payment) {withdrawal_transaction.payment}
    let(:reinstated_transaction) {dispute.dispute_transactions.order("date").second}
    let(:reinstated_payment) {reinstated_transaction.payment}

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

    describe "dispute" do
      subject { dispute }
      specify { expect(subject).to be_persisted }
      specify { expect(subject.gross_amount).to eq 80000 }
      specify { expect(subject.status).to eq "lost" }
      specify { expect(subject.reason).to eq 'duplicate' }
    end

    it 'has 1 dispute transactions' do
      expect(dispute_transactions.count).to eq 1
    end

    describe 'has a withdrawal_transaction' do
      subject{ withdrawal_transaction }
      specify { expect(subject).to be_persisted }
      specify { expect(subject.gross_amount).to eq -80000 }
      specify { expect(subject.fee_total).to eq -1500 }
      specify { expect(subject.stripe_transaction_id).to eq 'txn_1Y7pdnBCJIIhvMWmJ9KQVpfB' }
      specify { expect(subject.date).to eq DateTime.new(2020, 8, 3, 4, 55, 55)}
      specify { expect(subject.disbursed).to eq false }
    end

    describe 'has a withdrawal_payment' do
      subject { withdrawal_payment}
      specify { expect(subject).to be_persisted }
      specify { expect(subject.gross_amount).to eq -80000}
      specify { expect(subject.fee_total).to eq -1500}
      specify { expect(subject.kind).to eq 'Dispute'}
      specify { expect(subject.nonprofit).to eq supporter.nonprofit}
      specify { expect(subject.date).to eq DateTime.new(2020, 8, 3, 4, 55, 55)}
    end

    it 'has no reinstated transaction' do 
      expect(reinstated_transaction).to be_nil
    end
  end

  describe "dispute.created -> dispute.funds_withdrawn -> dispute.closed, status = lost " do
    let(:created_json) do
      event =StripeMock.mock_webhook_event('charge.dispute.created')
      event['data']['object']
    end
    let(:withdrawn_json) do
      event =StripeMock.mock_webhook_event('charge.dispute.funds_withdrawn')
      event['data']['object']
    end
    let(:lost_json) do
      event =StripeMock.mock_webhook_event('charge.dispute.closed-lost')
      event['data']['object']
    end
    let(:supporter) { force_create(:supporter)}
    let!(:charge) { force_create(:charge, supporter: supporter, stripe_charge_id: 'ch_1Y7zzfBCJIIhvMWmSiNWrPAC', nonprofit: supporter.nonprofit)}

    let(:obj) { 
      obj = StripeDispute.create(object:created_json); 
      obj.object = withdrawn_json;
      obj.save!
      obj.object = lost_json;
      obj.save!
      obj
    }

    let(:dispute) { obj.dispute }
    let(:dispute_transactions) { dispute.dispute_transactions }
    let(:withdrawal_transaction) {dispute.dispute_transactions.order("date").first}
    let(:withdrawal_payment) {withdrawal_transaction.payment}
    let(:reinstated_transaction) {dispute.dispute_transactions.order("date").second}
    let(:reinstated_payment) {reinstated_transaction.payment}

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

    describe "dispute" do
      subject { dispute }
      specify { expect(subject).to be_persisted }
      specify { expect(subject.gross_amount).to eq 80000 }
      specify { expect(subject.status).to eq "lost" }
      specify { expect(subject.reason).to eq 'duplicate' }
    end

    it 'has 1 dispute transactions' do
      expect(dispute_transactions.count).to eq 1
    end

    describe 'has a withdrawal_transaction' do
      subject{ withdrawal_transaction }
      specify { expect(subject).to be_persisted }
      specify { expect(subject.gross_amount).to eq -80000 }
      specify { expect(subject.fee_total).to eq -1500 }
      specify { expect(subject.stripe_transaction_id).to eq 'txn_1Y7pdnBCJIIhvMWmJ9KQVpfB' }
      specify { expect(subject.date).to eq DateTime.new(2020, 8, 3, 4, 55, 55)}
      specify { expect(subject.disbursed).to eq false }
    end

    describe 'has a withdrawal_payment' do
      subject { withdrawal_payment}
      specify { expect(subject).to be_persisted }
      specify { expect(subject.gross_amount).to eq -80000}
      specify { expect(subject.fee_total).to eq -1500}
      specify { expect(subject.kind).to eq 'Dispute'}
      specify { expect(subject.nonprofit).to eq supporter.nonprofit}
      specify { expect(subject.date).to eq DateTime.new(2020, 8, 3, 4, 55, 55)}
    end

    it 'has no reinstated transaction' do 
      expect(reinstated_transaction).to be_nil
    end
  end

  describe "dispute.created-with-one-withdrawn -> dispute.funds_withdrawn -> dispute.closed, status = lost " do
    let(:created_json) do
      event =StripeMock.mock_webhook_event('charge.dispute.created-with-one-withdrawn')
      event['data']['object']
    end
    let(:withdrawn_json) do
      event =StripeMock.mock_webhook_event('charge.dispute.funds_withdrawn')
      event['data']['object']
    end
    let(:lost_json) do
      event =StripeMock.mock_webhook_event('charge.dispute.closed-lost')
      event['data']['object']
    end
    let(:supporter) { force_create(:supporter)}
    let!(:charge) { force_create(:charge, supporter: supporter, stripe_charge_id: 'ch_1Y7zzfBCJIIhvMWmSiNWrPAC', nonprofit: supporter.nonprofit)}

    let(:obj) { 
      obj = StripeDispute.create(object:created_json); 
      obj.object = withdrawn_json;
      obj.save!
      obj.object = lost_json;
      obj.save!
      obj
    }

    let(:dispute) { obj.dispute }
    let(:dispute_transactions) { dispute.dispute_transactions }
    let(:withdrawal_transaction) {dispute.dispute_transactions.order("date").first}
    let(:withdrawal_payment) {withdrawal_transaction.payment}
    let(:reinstated_transaction) {dispute.dispute_transactions.order("date").second}
    let(:reinstated_payment) {reinstated_transaction.payment}

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

    describe "dispute" do
      subject { dispute }
      specify { expect(subject).to be_persisted }
      specify { expect(subject.gross_amount).to eq 80000 }
      specify { expect(subject.status).to eq "lost" }
      specify { expect(subject.reason).to eq 'duplicate' }
    end

    it 'has 1 dispute transactions' do
      expect(dispute_transactions.count).to eq 1
    end

    describe 'has a withdrawal_transaction' do
      subject{ withdrawal_transaction }
      specify { expect(subject).to be_persisted }
      specify { expect(subject.gross_amount).to eq -80000 }
      specify { expect(subject.fee_total).to eq -1500 }
      specify { expect(subject.stripe_transaction_id).to eq 'txn_1Y7pdnBCJIIhvMWmJ9KQVpfB' }
      specify { expect(subject.date).to eq DateTime.new(2020, 8, 3, 4, 55, 55)}
      specify { expect(subject.disbursed).to eq false }
    end

    describe 'has a withdrawal_payment' do
      subject { withdrawal_payment}
      specify { expect(subject).to be_persisted }
      specify { expect(subject.gross_amount).to eq -80000}
      specify { expect(subject.fee_total).to eq -1500}
      specify { expect(subject.kind).to eq 'Dispute'}
      specify { expect(subject.nonprofit).to eq supporter.nonprofit}
      specify { expect(subject.date).to eq DateTime.new(2020, 8, 3, 4, 55, 55)}
    end

    it 'has no reinstated transaction' do 
      expect(reinstated_transaction).to be_nil
    end
  end

  describe "dispute.closed, status = lost -> dispute.created -> dispute.funds_withdrawn" do
    let(:created_json) do
      event =StripeMock.mock_webhook_event('charge.dispute.created')
      event['data']['object']
    end
    let(:withdrawn_json) do
      event =StripeMock.mock_webhook_event('charge.dispute.funds_withdrawn')
      event['data']['object']
    end
    let(:lost_json) do
      event =StripeMock.mock_webhook_event('charge.dispute.closed-lost')
      event['data']['object']
    end
    let(:supporter) { force_create(:supporter)}
    let!(:charge) { force_create(:charge, supporter: supporter, stripe_charge_id: 'ch_1Y7zzfBCJIIhvMWmSiNWrPAC', nonprofit: supporter.nonprofit)}

    let(:obj) { 
      obj = StripeDispute.create(object:lost_json); 
      obj.object = created_json;
      obj.save!
      obj.object = withdrawn_json;
      obj.save!
      obj
    }

    let(:dispute) { obj.dispute }
    let(:dispute_transactions) { dispute.dispute_transactions }
    let(:withdrawal_transaction) {dispute.dispute_transactions.order("date").first}
    let(:withdrawal_payment) {withdrawal_transaction.payment}
    let(:reinstated_transaction) {dispute.dispute_transactions.order("date").second}
    let(:reinstated_payment) {reinstated_transaction.payment}

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

    describe "dispute" do
      subject { dispute }
      specify { expect(subject).to be_persisted }
      specify { expect(subject.gross_amount).to eq 80000 }
      specify { expect(subject.status).to eq "lost" }
      specify { expect(subject.reason).to eq 'duplicate' }
    end

    it 'has 1 dispute transactions' do
      expect(dispute_transactions.count).to eq 1
    end

    describe 'has a withdrawal_transaction' do
      subject{ withdrawal_transaction }
      specify { expect(subject).to be_persisted }
      specify { expect(subject.gross_amount).to eq -80000 }
      specify { expect(subject.fee_total).to eq -1500 }
      specify { expect(subject.stripe_transaction_id).to eq 'txn_1Y7pdnBCJIIhvMWmJ9KQVpfB' }
      specify { expect(subject.date).to eq DateTime.new(2020, 8, 3, 4, 55, 55)}
      specify { expect(subject.disbursed).to eq false }
    end

    describe 'has a withdrawal_payment' do
      subject { withdrawal_payment}
      specify { expect(subject).to be_persisted }
      specify { expect(subject.gross_amount).to eq -80000}
      specify { expect(subject.fee_total).to eq -1500}
      specify { expect(subject.kind).to eq 'Dispute'}
      specify { expect(subject.nonprofit).to eq supporter.nonprofit}
      specify { expect(subject.date).to eq DateTime.new(2020, 8, 3, 4, 55, 55)}
    end

    it 'has no reinstated transaction' do 
      expect(reinstated_transaction).to be_nil
    end
  end

  describe "dispute.closed, status = won" do
    let(:json) do
      event =StripeMock.mock_webhook_event('charge.dispute.closed-won')
      event['data']['object']
    end

    let(:supporter) { force_create(:supporter)}
    let!(:charge) { force_create(:charge, supporter: supporter, stripe_charge_id: 'ch_1Y7vFYBCJIIhvMWmsdRJWSw5', nonprofit: supporter.nonprofit)}

    let(:obj) { StripeDispute.create(object:json) }

    let(:dispute) { obj.dispute }
    let(:dispute_transactions) { dispute.dispute_transactions }
    let(:withdrawal_transaction) {dispute.dispute_transactions.order("date").first}
    let(:withdrawal_payment) {withdrawal_transaction.payment}
    let(:reinstated_transaction) {dispute.dispute_transactions.order("date").second}
    let(:reinstated_payment) {reinstated_transaction.payment}

    it 'has status of won' do 
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
    
    describe "dispute" do
      subject { dispute }
      specify { expect(subject).to be_persisted }
      specify { expect(subject.gross_amount).to eq 22500 }
      specify { expect(subject.status).to eq "won" }
      specify { expect(subject.reason).to eq 'credit_not_processed' }
    end

    it 'has two dispute transactions' do
      expect(dispute_transactions.count).to eq 2
    end

    describe 'has a withdrawal_transaction' do
      subject{ withdrawal_transaction }
      specify {  expect(subject).to be_persisted }
      specify {  expect(subject.gross_amount).to eq -22500 }
      specify {  expect(subject.fee_total).to eq -1500 }
      specify {  expect(subject.stripe_transaction_id).to eq 'txn_1Y75JVBCJIIhvMWmsnGK1JLD' }
      specify { expect(subject.date).to eq DateTime.new(2019,8,5,12,29,20)}
      specify { expect(subject.disbursed).to eq false }
    end

    describe 'has a withdrawal_payment' do
      subject { withdrawal_payment}
      specify { expect(subject).to be_persisted }
      specify { expect(subject.gross_amount).to eq -22500}
      specify { expect(subject.fee_total).to eq -1500}
      specify { expect(subject.kind).to eq 'Dispute'}
      specify { expect(subject.nonprofit).to eq supporter.nonprofit}
      specify { expect(subject.date).to eq DateTime.new(2019,8,5,12,29,20)}
    end


    describe 'has a reinstated_transaction' do
      subject{ reinstated_transaction }
      specify {  expect(subject).to be_persisted }
      specify {  expect(subject.gross_amount).to eq 22500 }
      specify {  expect(subject.fee_total).to eq 1500 }
      specify {  expect(subject.stripe_transaction_id).to eq 'txn_1Y71X0BCJIIhvMWmMmtTY4m1' }
      specify { expect(subject.date).to eq DateTime.new(2019,10,29,20,43,10)}
      specify { expect(subject.disbursed).to eq false }
    end

    describe 'has a reinstated_payment' do
      subject { reinstated_payment}
      specify { expect(subject).to be_persisted }
      specify { expect(subject.gross_amount).to eq 22500}
      specify { expect(subject.fee_total).to eq 1500}
      specify { expect(subject.kind).to eq 'DisputeReversed'}
      specify { expect(subject.nonprofit).to eq supporter.nonprofit}
      specify { expect(subject.date).to eq DateTime.new(2019,10,29,20,43,10)}
    end
  end

  describe '.dispute' do
    let(:stripe_dispute) { force_create(:stripe_dispute, stripe_dispute_id: 'test_dispute_id')}
    it 'directs to a dispute with the correct Stripe dispute id' do
      expect(stripe_dispute.dispute).to eq Dispute.where(stripe_dispute_id: 'test_dispute_id').first
    end
  end

  describe '.charge' do
    let!(:charge){ force_create(:charge, stripe_charge_id: 'test_ch_id')}
    let(:stripe_dispute) { create(:stripe_dispute, stripe_charge_id: 'test_ch_id')}
    it 'directs to a dispute with the correct Stripe charge id' do
      expect(stripe_dispute.charge).to eq charge
    end
  end
end
