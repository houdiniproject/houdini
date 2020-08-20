RSpec.shared_context :disputes_context do
  around(:each) do |example|
    StripeMock.start
      example.run
    StripeMock.stop
  end

  let(:stripe_helper) { StripeMock.create_test_helper }
  let(:nonprofit) { force_create(:nonprofit)}
  let(:supporter) { force_create(:supporter, nonprofit: nonprofit)}
  let(:json) do
    event_json['data']['object']
  end

  let(:dispute) { obj.dispute }
  let(:dispute_transactions) { dispute.dispute_transactions }

  let(:withdrawal_transaction) {dispute.dispute_transactions.order("date").first}
  let(:withdrawal_payment) {withdrawal_transaction.payment}
  let(:reinstated_transaction) {dispute.dispute_transactions.order("date").second}
  let(:reinstated_payment) {reinstated_transaction.payment}
end

RSpec.shared_context :dispute_created_context do 
  include_context :disputes_context do 

    let(:event_json) do 
      event_json = StripeMock.mock_webhook_event('charge.dispute.created')
      stripe_helper.upsert_stripe_object(:dispute, event_json['data']['object'])
      event_json
    end

    let!(:charge) { force_create(:charge, supporter: supporter, 
      stripe_charge_id: 'ch_1Y7zzfBCJIIhvMWmSiNWrPAC', nonprofit: nonprofit, payment:force_create(:payment,
        supporter:supporter,
        nonprofit: nonprofit,
        gross_amount: 80000))}
  end
end

RSpec.shared_context :dispute_created_specs do
  include_context :dispute_created_context

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
    expect(obj.stripe_dispute_id).to eq "dp_05RsQX2eZvKYlo2C0FRTGSSA"
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

RSpec.shared_context :dispute_funds_withdrawn_context do 
  include_context :disputes_context do 

    let(:event_json) do 
      event_json = StripeMock.mock_webhook_event('charge.dispute.funds_withdrawn')
      stripe_helper.upsert_stripe_object(:dispute, event_json['data']['object'])
      event_json
    end

    let!(:charge) { force_create(:charge, supporter: supporter, 
      stripe_charge_id: 'ch_1Y7zzfBCJIIhvMWmSiNWrPAC', nonprofit: nonprofit, payment:force_create(:payment,
         supporter:supporter,
        nonprofit: nonprofit,
        gross_amount: 80000))}
    
  end
end

RSpec.shared_context :dispute_funds_withdrawn_specs do
  include_context :dispute_funds_withdrawn_context

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
    expect(obj.stripe_dispute_id).to eq "dp_05RsQX2eZvKYlo2C0FRTGSSA"
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
    specify { expect(subject.net_amount).to eq -81500}
    specify { expect(subject.kind).to eq 'Dispute'}
    specify { expect(subject.nonprofit).to eq supporter.nonprofit}
    specify { expect(subject.date).to eq DateTime.new(2020, 8, 3, 4, 55, 55)}
  end
end

RSpec.shared_context :dispute_funds_reinstated_context do
  include_context :disputes_context
  let(:event_json) do
    event_json =StripeMock.mock_webhook_event('charge.dispute.funds_reinstated')
    stripe_helper.upsert_stripe_object(:dispute, event_json['data']['object'])
    event_json
  end
  let!(:charge) { force_create(:charge, supporter: supporter, 
    stripe_charge_id: 'ch_1Y7vFYBCJIIhvMWmsdRJWSw5', nonprofit: nonprofit, payment:force_create(:payment,
       supporter:supporter,
      nonprofit: nonprofit,
      gross_amount: 22500))}
end

RSpec.shared_context :dispute_funds_reinstated_specs do
  include_context :dispute_funds_reinstated_context

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
    expect(obj.stripe_dispute_id).to eq "dp_15RsQX2eZvKYlo2C0ERTYUIA"
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
    specify { expect(subject.net_amount).to eq -24000}
    specify { expect(subject.kind).to eq 'Dispute'}
    specify { expect(subject.nonprofit).to eq supporter.nonprofit}
    specify { expect(subject.date).to eq DateTime.new(2019,9,4,13,29,20)}
  end


  describe 'has a reinstated_transaction' do
    subject{ reinstated_transaction }
    specify {  expect(subject).to be_persisted }
    specify {  expect(subject.gross_amount).to eq 22500 }
    specify {  expect(subject.fee_total).to eq 1500 }
    specify { expect(subject.net_amount).to eq 24000}
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

RSpec.shared_context :dispute_lost_context do
  include_context :disputes_context
  let(:event_json) do
    event_json =StripeMock.mock_webhook_event('charge.dispute.closed-lost')
    stripe_helper.upsert_stripe_object(:dispute, event_json['data']['object'])
    event_json
  end
  let!(:charge) { force_create(:charge, supporter: supporter, 
    stripe_charge_id: 'ch_1Y7zzfBCJIIhvMWmSiNWrPAC', nonprofit: nonprofit, payment:force_create(:payment,
      supporter:supporter,
      nonprofit: nonprofit,
      gross_amount: 80000))}
end

RSpec.shared_context :dispute_lost_specs do
  include_context :dispute_lost_context

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
    expect(obj.stripe_dispute_id).to eq "dp_05RsQX2eZvKYlo2C0FRTGSSA"
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
    specify { expect(subject.net_amount).to eq -81500}
    specify { expect(subject.kind).to eq 'Dispute'}
    specify { expect(subject.nonprofit).to eq supporter.nonprofit}
    specify { expect(subject.date).to eq DateTime.new(2020, 8, 3, 4, 55, 55)}
  end

  it 'has no reinstated transaction' do 
    expect(reinstated_transaction).to be_nil
  end
end

RSpec.shared_context :dispute_won_context do
  include_context :disputes_context
  let(:event_json) do
    event_json =StripeMock.mock_webhook_event('charge.dispute.closed-won')
    stripe_helper.upsert_stripe_object(:dispute, event_json['data']['object'])
    event_json
  end
  let!(:charge) { force_create(:charge, supporter: supporter, 
    stripe_charge_id: 'ch_1Y7vFYBCJIIhvMWmsdRJWSw5', nonprofit: nonprofit, payment:force_create(:payment,
       supporter:supporter,
      nonprofit: nonprofit,
      gross_amount: 22500))}
end

RSpec.shared_context :dispute_won_specs do
  include_context :dispute_won_context

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
    expect(obj.stripe_dispute_id).to eq "dp_15RsQX2eZvKYlo2C0ERTYUIA"
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
    specify { expect(subject.net_amount).to eq -24000 }
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
    specify { expect(subject.net_amount).to eq 24000 }
    specify { expect(subject.kind).to eq 'DisputeReversed'}
    specify { expect(subject.nonprofit).to eq supporter.nonprofit}
    specify { expect(subject.date).to eq DateTime.new(2019,10,29,20,43,10)}
  end
end


RSpec.shared_context :dispute_created_and_withdrawn_at_same_time_context do 
  include_context :disputes_context
  let(:event_json_created) do
    StripeMock.mock_webhook_event('charge.dispute.created-with-one-withdrawn')
  end

  let(:json_created) { event_json_created['data']['object']}

  let(:json_funds_withdrawn) {event_json_funds_withdrawn['data']['object']}

  let(:event_json_funds_withdrawn) do
    json = StripeMock.mock_webhook_event('charge.dispute.funds_withdrawn')
    stripe_helper.upsert_stripe_object(:dispute, json['data']['object'])
    json
  end

  let!(:charge) { force_create(:charge, supporter: supporter, 
    stripe_charge_id: 'ch_1Y7zzfBCJIIhvMWmSiNWrPAC', nonprofit: nonprofit, payment:force_create(:payment,
       supporter:supporter,
      nonprofit: nonprofit,
      gross_amount: 80000))}
end

RSpec.shared_context :dispute_created_and_withdrawn_at_same_time_specs do
  include_context :dispute_created_and_withdrawn_at_same_time_context

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
    expect(obj.stripe_dispute_id).to eq "dp_05RsQX2eZvKYlo2C0FRTGSSA"
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
    specify { expect(subject.net_amount).to eq -81500}
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
    expect(Payment.count).to eq 2 #one for charge, one for DisputeTransaction
  end

  it 'has only one dispute transaction' do 
    obj
    expect(DisputeTransaction.count).to eq 1
  end
end