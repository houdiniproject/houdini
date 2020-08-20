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
    let(:dispute) { obj.dispute }
    let(:dispute_transactions) { dispute.dispute_transactions }
  end
end

RSpec.shared_context :dispute_created_verify_entity_context do
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