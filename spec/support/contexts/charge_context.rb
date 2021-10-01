RSpec.shared_context :charge_context do
  around(:each) do |example|
    StripeMock.start
      example.run
    StripeMock.stop
  end

  let(:stripe_helper) { StripeMock.create_test_helper }
  let(:json) do
    event_json['data']['object']
  end

 
end


RSpec.shared_context :charge_succeeded_context do 
  include_context :charge_context do 

    let(:event_json) do 
      event_json = StripeMock.mock_webhook_event('charge.succeeded')
      event_json
    end
  end
end

RSpec.shared_context :charge_succeeded_specs do
  include_context :charge_succeeded_context

  it 'has a correct charge id ' do 
    expect(obj.stripe_charge_id).to eq "ch_1Y7zzfBCJIIhvMWmSiNWrPAC"
  end
end

