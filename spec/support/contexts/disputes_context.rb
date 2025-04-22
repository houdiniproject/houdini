RSpec.shared_context :disputes_context do
  around(:each) do |example|
    StripeMockHelper.mock do
      example.run
    end
  end

  let(:nonprofit) { force_create(:nonprofit) }
  let(:supporter) { force_create(:supporter, nonprofit: nonprofit) }
  let(:json) do
    event_json["data"]["object"]
  end

  let(:dispute_created_time) { Time.at(1596429790) }
  let(:dispute_created_time__partial1) { dispute_created_time }

  let(:dispute_withdrawal_payment_time) { Time.at(1596430500) }
  let(:dispute_withdrawal_payment_time__partial1) { dispute_withdrawal_payment_time }

  let(:dispute_created__partial2) { Time.at(1596430600) }

  let(:dispute_withdrawal_payment_time__partial2) { Time.at(1596430650) }

  let(:dispute_reinstatement_payment_time) { Time.at(1596432510) }

  let(:dispute) { obj.dispute }
  let(:dispute_transactions) { dispute.dispute_transactions }

  # we reload this because we'll get the older version if we don't
  let(:original_payment) {
    obj.dispute.original_payment.reload
    obj.dispute.original_payment
  }

  let(:withdrawal_transaction) { dispute.dispute_transactions.order("date").first }
  let(:withdrawal_payment) { withdrawal_transaction.payment }
  let(:reinstated_transaction) { dispute.dispute_transactions.order("date").second }
  let(:reinstated_payment) { reinstated_transaction.payment }
end

RSpec.shared_context :disputes_specs do
  before(:each) do
    allow(JobQueue).to receive(:queue)
  end

  all_events = [:created, :updated, :funds_reinstated, :funds_withdrawn, :won, :lost]

  it "has correct events in order" do
    valid_events.each do |t|
      job_type = ("JobTypes::Dispute" + t.to_s.camelize + "Job").constantize
      expect(JobQueue).to have_received(:queue).with(
        job_type, dispute
      ).ordered
    end
  end

  it "does not have invalid events" do
    invalid_events = all_events - valid_events
    invalid_events.each do |t|
      job_type = ("JobTypes::Dispute" + t.to_s.camelize + "Job").constantize
      expect(JobQueue).to_not have_received(:queue).with(
        job_type
      )
    end
  end

  it "has valid activities" do
    valid_events.each do |t|
      dispute_kind = "Dispute" + t.to_s.camelize
      case t
      when :funds_withdrawn
        expect(withdrawal_transaction.payment.activities.where(kind: dispute_kind).count).to eq 1
      when :funds_reinstated
        expect(reinstated_transaction.payment.activities.where(kind: dispute_kind).count).to eq 1
      else
        expect(dispute.activities.where(kind: dispute_kind).count).to eq 1
      end
    end
  end

  it "does not have invalid activities" do
    invalid_events = all_events - valid_events
    invalid_events.each do |t|
      dispute_kind = "Dispute" + t.to_s.camelize
      case t
      when :funds_withdrawn
        if withdrawal_transaction
          expect(withdrawal_transaction.payment.activities.where(kind: dispute_kind)).to be_empty, "#{dispute_kind} should not have been here."
        end
      when :funds_reinstated
        if reinstated_transaction
          expect(reinstated_transaction.payment.activities.where(kind: dispute_kind)).to be_empty, "#{dispute_kind} should not have been here."
        end
      else
        # byebug if dispute_kind == "DisputeUpdated" && dispute.activities.where(kind: dispute_kind).any?
        expect(dispute.activities.where(kind: dispute_kind)).to be_empty, "#{dispute_kind} should not have been here."
      end
    end
  end
end

RSpec.shared_context :dispute_created_context do
  include_context :disputes_context do
    let(:event_json) do
      event_json = StripeMockHelper.mock_webhook_event("charge.dispute.created")
      StripeMockHelper.stripe_helper.upsert_stripe_object(:dispute, event_json["data"]["object"])
      event_json
    end

    let!(:charge) {
      force_create(:charge, supporter: supporter,
        stripe_charge_id: "ch_1Y7zzfBCJIIhvMWmSiNWrPAC", nonprofit: nonprofit, payment: force_create(:payment,
          supporter: supporter,
          nonprofit: nonprofit,
          gross_amount: 80000))
    }
  end
end

RSpec.shared_context :dispute_created_specs do
  include_context :dispute_created_context
  include_context :disputes_specs

  it "has status of needs_response" do
    expect(obj.status).to eq "needs_response"
  end

  it "has reason of duplicate" do
    expect(obj.reason).to eq "duplicate"
  end

  it "has 0 balance transactions" do
    expect(obj.balance_transactions.count).to eq 0
  end

  it "has a net_change of 0" do
    expect(obj.net_change).to eq 0
  end

  it "has an amount of 80000" do
    expect(obj.amount).to eq 80000
  end

  it "has a correct charge id " do
    expect(obj.stripe_charge_id).to eq "ch_1Y7zzfBCJIIhvMWmSiNWrPAC"
  end

  it "has a correct dispute id" do
    expect(obj.stripe_dispute_id).to eq "dp_05RsQX2eZvKYlo2C0FRTGSSA"
  end

  it "has a started_at of dispute_created_time" do
    expect(obj.started_at).to eq dispute_created_time
  end

  it "has a saved dispute" do
    expect(dispute).to be_persisted
  end

  it "has a dispute with 80000" do
    expect(dispute.gross_amount).to eq 80000
  end

  it "has a dispute with status of needs_response" do
    expect(dispute.status).to eq "needs_response"
  end

  it "has a dispute with reason of duplicate" do
    expect(dispute.reason).to eq "duplicate"
  end

  it "has a dispute with started_at of dispute_created_time" do
    expect(dispute.started_at).to eq dispute_created_time
  end

  it "has no dispute transactions" do
    expect(dispute_transactions).to eq []
  end

  specify { expect(original_payment.refund_total).to eq 0 }

  let(:valid_events) { [:created] }
end

RSpec.shared_context :dispute_funds_withdrawn_context do
  include_context :disputes_context do
    let(:event_json) do
      event_json = StripeMockHelper.mock_webhook_event("charge.dispute.funds_withdrawn")
      StripeMockHelper.stripe_helper.upsert_stripe_object(:dispute, event_json["data"]["object"])
      event_json
    end

    let!(:charge) {
      force_create(:charge, supporter: supporter,
        stripe_charge_id: "ch_1Y7zzfBCJIIhvMWmSiNWrPAC", nonprofit: nonprofit, payment: force_create(:payment,
          supporter: supporter,
          nonprofit: nonprofit,
          gross_amount: 80000))
    }
  end
end

RSpec.shared_context :dispute_funds_withdrawn_specs do
  include_context :dispute_funds_withdrawn_context
  include_context :disputes_specs

  it "has status of needs_response" do
    expect(obj.status).to eq "needs_response"
  end

  it "has reason of duplicate" do
    expect(obj.reason).to eq "duplicate"
  end

  it "has 1 balance transactions" do
    expect(obj.balance_transactions.count).to eq 1
  end

  it "has a net_change of -81500" do
    expect(obj.net_change).to eq(-81500)
  end

  it "has an amount of 80000" do
    expect(obj.amount).to eq 80000
  end

  it "has a correct charge id " do
    expect(obj.stripe_charge_id).to eq "ch_1Y7zzfBCJIIhvMWmSiNWrPAC"
  end

  it "has a correct dispute id" do
    expect(obj.stripe_dispute_id).to eq "dp_05RsQX2eZvKYlo2C0FRTGSSA"
  end

  it "has a started_at of dispute_created_time" do
    expect(obj.started_at).to eq dispute_created_time
  end

  describe "dispute" do
    subject { dispute }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq 80000 }
    specify { expect(subject.status).to eq "needs_response" }
    specify { expect(subject.reason).to eq "duplicate" }
    specify { expect(subject.started_at).to eq dispute_created_time }
  end

  it "has one dispute transaction" do
    expect(dispute_transactions.count).to eq 1
  end

  describe "has a withdrawal_transaction" do
    subject { withdrawal_transaction }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq(-80000) }
    specify { expect(subject.fee_total).to eq(-1500) }
    specify { expect(subject.stripe_transaction_id).to eq "txn_1Y7pdnBCJIIhvMWmJ9KQVpfB" }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.date).to eq dispute_withdrawal_payment_time }
    specify { expect(subject.disbursed).to eq false }
  end

  describe "has a withdrawal_payment" do
    subject { withdrawal_payment }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq(-80000) }
    specify { expect(subject.fee_total).to eq(-1500) }
    specify { expect(subject.net_amount).to eq(-81500) }
    specify { expect(subject.kind).to eq "Dispute" }
    specify { expect(subject.nonprofit).to eq supporter.nonprofit }
    specify { expect(subject.date).to eq dispute_withdrawal_payment_time }
  end

  specify { expect(original_payment.refund_total).to eq 80000 }

  let(:valid_events) { [:created, :funds_withdrawn] }
end

RSpec.shared_context :dispute_funds_reinstated_context do
  include_context :disputes_context
  let(:event_json) do
    event_json = StripeMockHelper.mock_webhook_event("charge.dispute.funds_reinstated")
    StripeMockHelper.stripe_helper.upsert_stripe_object(:dispute, event_json["data"]["object"])
    event_json
  end
  let!(:charge) {
    force_create(:charge, supporter: supporter,
      stripe_charge_id: "ch_1Y7zzfBCJIIhvMWmSiNWrPAC", nonprofit: nonprofit, payment: force_create(:payment,
        supporter: supporter,
        nonprofit: nonprofit,
        gross_amount: 80000))
  }
end

RSpec.shared_context :dispute_funds_reinstated_specs do
  include_context :dispute_funds_reinstated_context
  include_context :disputes_specs

  it "has status of under_review" do
    expect(obj.status).to eq "under_review"
  end

  it "has reason of credit_not_processed" do
    expect(obj.reason).to eq "credit_not_processed"
  end

  it "has 0 balance transactions" do
    expect(obj.balance_transactions.count).to eq 2
  end

  it "has a net_change of 0" do
    expect(obj.net_change).to eq 0
  end

  it "has an amount of 80000" do
    expect(obj.amount).to eq 80000
  end

  it "has a correct charge id " do
    expect(obj.stripe_charge_id).to eq "ch_1Y7zzfBCJIIhvMWmSiNWrPAC"
  end

  it "has a correct dispute id" do
    expect(obj.stripe_dispute_id).to eq "dp_05RsQX2eZvKYlo2C0FRTGSSA"
  end

  it "has a started_at of dispute_created_time" do
    expect(obj.started_at).to eq dispute_created_time
  end

  describe "dispute" do
    subject { dispute }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq 80000 }
    specify { expect(subject.status).to eq "under_review" }
    specify { expect(subject.reason).to eq "credit_not_processed" }
    specify { expect(subject.started_at).to eq dispute_created_time }
  end

  it "has two dispute transactions" do
    expect(dispute_transactions.count).to eq 2
  end

  describe "has a withdrawal_transaction" do
    subject { withdrawal_transaction }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq(-80000) }
    specify { expect(subject.fee_total).to eq(-1500) }
    specify { expect(subject.stripe_transaction_id).to eq "txn_1Y75JVBCJIIhvMWmsnGK1JLD" }
    specify { expect(subject.date).to eq dispute_withdrawal_payment_time }
    specify { expect(subject.disbursed).to eq false }
  end

  describe "has a withdrawal_payment" do
    subject { withdrawal_payment }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq(-80000) }
    specify { expect(subject.fee_total).to eq(-1500) }
    specify { expect(subject.net_amount).to eq(-81500) }
    specify { expect(subject.kind).to eq "Dispute" }
    specify { expect(subject.nonprofit).to eq supporter.nonprofit }
    specify { expect(subject.date).to eq dispute_withdrawal_payment_time }
  end

  describe "has a reinstated_transaction" do
    subject { reinstated_transaction }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq 80000 }
    specify { expect(subject.fee_total).to eq 1500 }
    specify { expect(subject.net_amount).to eq 81500 }
    specify { expect(subject.stripe_transaction_id).to eq "txn_1Y71X0BCJIIhvMWmMmtTY4m1" }
    specify { expect(subject.date).to eq dispute_reinstatement_payment_time }
    specify { expect(subject.disbursed).to eq false }
  end

  describe "has a reinstated_payment" do
    subject { reinstated_payment }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq 80000 }
    specify { expect(subject.fee_total).to eq 1500 }
    specify { expect(subject.kind).to eq "DisputeReversed" }
    specify { expect(subject.nonprofit).to eq supporter.nonprofit }
    specify { expect(subject.date).to eq dispute_reinstatement_payment_time }
  end

  specify { expect(original_payment.refund_total).to eq 0 }

  let(:valid_events) { [:created, :funds_withdrawn, :funds_reinstated] }
end

RSpec.shared_context :dispute_lost_context do
  include_context :disputes_context
  let(:event_json) do
    event_json = StripeMockHelper.mock_webhook_event("charge.dispute.closed-lost")
    StripeMockHelper.stripe_helper.upsert_stripe_object(:dispute, event_json["data"]["object"])
    event_json
  end
  let!(:charge) {
    force_create(:charge, supporter: supporter,
      stripe_charge_id: "ch_1Y7zzfBCJIIhvMWmSiNWrPAC", nonprofit: nonprofit, payment: force_create(:payment,
        supporter: supporter,
        nonprofit: nonprofit,
        gross_amount: 80000))
  }
end

RSpec.shared_context :dispute_lost_specs do
  include_context :dispute_lost_context
  include_context :disputes_specs

  it "has status of under_review" do
    expect(obj.status).to eq "lost"
  end

  it "has reason of credit_not_processed" do
    expect(obj.reason).to eq "duplicate"
  end

  it "has 1 balance transactions" do
    expect(obj.balance_transactions.count).to eq 1
  end

  it "has a net_change of -81500" do
    expect(obj.net_change).to eq(-81500)
  end

  it "has an amount of 80000" do
    expect(obj.amount).to eq 80000
  end

  it "has a correct charge id" do
    expect(obj.stripe_charge_id).to eq "ch_1Y7zzfBCJIIhvMWmSiNWrPAC"
  end

  it "has a correct dispute id" do
    expect(obj.stripe_dispute_id).to eq "dp_05RsQX2eZvKYlo2C0FRTGSSA"
  end

  it "has a started_at of dispute_created_time" do
    expect(obj.started_at).to eq dispute_created_time
  end

  describe "dispute" do
    subject { dispute }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq 80000 }
    specify { expect(subject.status).to eq "lost" }
    specify { expect(subject.reason).to eq "duplicate" }
    specify { expect(subject.started_at).to eq dispute_created_time }
  end

  it "has 1 dispute transactions" do
    expect(dispute_transactions.count).to eq 1
  end

  describe "has a withdrawal_transaction" do
    subject { withdrawal_transaction }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq(-80000) }
    specify { expect(subject.fee_total).to eq(-1500) }
    specify { expect(subject.stripe_transaction_id).to eq "txn_1Y7pdnBCJIIhvMWmJ9KQVpfB" }
    specify { expect(subject.date).to eq dispute_withdrawal_payment_time }
    specify { expect(subject.disbursed).to eq false }
  end

  describe "has a withdrawal_payment" do
    subject { withdrawal_payment }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq(-80000) }
    specify { expect(subject.fee_total).to eq(-1500) }
    specify { expect(subject.net_amount).to eq(-81500) }
    specify { expect(subject.kind).to eq "Dispute" }
    specify { expect(subject.nonprofit).to eq supporter.nonprofit }
    specify { expect(subject.date).to eq dispute_withdrawal_payment_time }
  end

  it "has no reinstated transaction" do
    expect(reinstated_transaction).to be_nil
  end

  let(:valid_events) { [:created, :funds_withdrawn, :lost] }
end

RSpec.shared_context :dispute_won_context do
  include_context :disputes_context
  let(:event_json) do
    event_json = StripeMockHelper.mock_webhook_event("charge.dispute.closed-won")
    StripeMockHelper.stripe_helper.upsert_stripe_object(:dispute, event_json["data"]["object"])
    event_json
  end
  let!(:charge) {
    force_create(:charge, supporter: supporter,
      stripe_charge_id: "ch_1Y7zzfBCJIIhvMWmSiNWrPAC", nonprofit: nonprofit, payment: force_create(:payment,
        supporter: supporter,
        nonprofit: nonprofit,
        gross_amount: 80000))
  }
end

RSpec.shared_context :dispute_won_specs do
  include_context :dispute_won_context
  include_context :disputes_specs

  it "has status of won" do
    expect(obj.status).to eq "won"
  end

  it "has reason of credit_not_processed" do
    expect(obj.reason).to eq "credit_not_processed"
  end

  it "has 2 balance transactions" do
    expect(obj.balance_transactions.count).to eq 2
  end

  it "has a net_change of 0" do
    expect(obj.net_change).to eq 0
  end

  it "has an amount of 80000" do
    expect(obj.amount).to eq 80000
  end

  it "has a correct charge id " do
    expect(obj.stripe_charge_id).to eq "ch_1Y7zzfBCJIIhvMWmSiNWrPAC"
  end

  it "has a correct dispute id" do
    expect(obj.stripe_dispute_id).to eq "dp_05RsQX2eZvKYlo2C0FRTGSSA"
  end

  it "has a started_at of dispute_created_time" do
    expect(obj.started_at).to eq dispute_created_time
  end

  describe "dispute" do
    subject { dispute }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq 80000 }
    specify { expect(subject.status).to eq "won" }
    specify { expect(subject.reason).to eq "credit_not_processed" }
    specify { expect(subject.started_at).to eq dispute_created_time }
  end

  it "has two dispute transactions" do
    expect(dispute_transactions.count).to eq 2
  end

  describe "has a withdrawal_transaction" do
    subject { withdrawal_transaction }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq(-80000) }
    specify { expect(subject.fee_total).to eq(-1500) }
    specify { expect(subject.stripe_transaction_id).to eq "txn_1Y75JVBCJIIhvMWmsnGK1JLD" }
    specify { expect(subject.date).to eq dispute_withdrawal_payment_time }
    specify { expect(subject.disbursed).to eq false }
  end

  describe "has a withdrawal_payment" do
    subject { withdrawal_payment }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq(-80000) }
    specify { expect(subject.fee_total).to eq(-1500) }
    specify { expect(subject.net_amount).to eq(-81500) }
    specify { expect(subject.kind).to eq "Dispute" }
    specify { expect(subject.nonprofit).to eq supporter.nonprofit }
    specify { expect(subject.date).to eq dispute_withdrawal_payment_time }
  end

  describe "has a reinstated_transaction" do
    subject { reinstated_transaction }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq 80000 }
    specify { expect(subject.fee_total).to eq 1500 }
    specify { expect(subject.stripe_transaction_id).to eq "txn_1Y71X0BCJIIhvMWmMmtTY4m1" }
    specify { expect(subject.date).to eq dispute_reinstatement_payment_time }
    specify { expect(subject.disbursed).to eq false }
  end

  describe "has a reinstated_payment" do
    subject { reinstated_payment }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq 80000 }
    specify { expect(subject.fee_total).to eq 1500 }
    specify { expect(subject.net_amount).to eq 81500 }
    specify { expect(subject.kind).to eq "DisputeReversed" }
    specify { expect(subject.nonprofit).to eq supporter.nonprofit }
    specify { expect(subject.date).to eq dispute_reinstatement_payment_time }
  end

  specify { expect(original_payment.refund_total).to eq 0 }

  let(:valid_events) { [:created, :funds_withdrawn, :funds_reinstated, :won] }
end

RSpec.shared_context :dispute_created_and_withdrawn_at_same_time_context do
  include_context :disputes_context
  let(:event_json_created) do
    StripeMockHelper.mock_webhook_event("charge.dispute.created-with-one-withdrawn")
  end

  let(:json_created) { event_json_created["data"]["object"] }

  let(:json_funds_withdrawn) { event_json_funds_withdrawn["data"]["object"] }

  let(:event_json_funds_withdrawn) do
    json = StripeMockHelper.mock_webhook_event("charge.dispute.funds_withdrawn")
    StripeMockHelper.stripe_helper.upsert_stripe_object(:dispute, json["data"]["object"])
    json
  end

  let!(:charge) {
    force_create(:charge, supporter: supporter,
      stripe_charge_id: "ch_1Y7zzfBCJIIhvMWmSiNWrPAC", nonprofit: nonprofit, payment: force_create(:payment,
        supporter: supporter,
        nonprofit: nonprofit,
        gross_amount: 80000))
  }
end

RSpec.shared_context :dispute_created_and_withdrawn_at_same_time_specs do
  include_context :dispute_created_and_withdrawn_at_same_time_context
  include_context :disputes_specs

  it "has status of needs_response" do
    expect(obj.status).to eq "needs_response"
  end

  it "has reason of duplicate" do
    expect(obj.reason).to eq "duplicate"
  end

  it "has 1 balance transactions" do
    expect(obj.balance_transactions.count).to eq 1
  end

  it "has a net_change of -81500" do
    expect(obj.net_change).to eq(-81500)
  end

  it "has an amount of 80000" do
    expect(obj.amount).to eq 80000
  end

  it "has a correct charge id " do
    expect(obj.stripe_charge_id).to eq "ch_1Y7zzfBCJIIhvMWmSiNWrPAC"
  end

  it "has a correct dispute id" do
    expect(obj.stripe_dispute_id).to eq "dp_05RsQX2eZvKYlo2C0FRTGSSA"
  end

  it "has a started_at of dispute_created_time" do
    expect(obj.started_at).to eq dispute_created_time
  end

  describe "dispute" do
    subject { dispute }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq 80000 }
    specify { expect(subject.status).to eq "needs_response" }
    specify { expect(subject.reason).to eq "duplicate" }
    specify { expect(subject.started_at).to eq dispute_created_time }
  end

  it "has one dispute transaction" do
    expect(dispute_transactions.count).to eq 1
  end

  describe "has a withdrawal_transaction" do
    subject { withdrawal_transaction }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq(-80000) }
    specify { expect(subject.fee_total).to eq(-1500) }
    specify { expect(subject.net_amount).to eq(-81500) }
    specify { expect(subject.stripe_transaction_id).to eq "txn_1Y7pdnBCJIIhvMWmJ9KQVpfB" }
    specify { expect(subject.date).to eq dispute_withdrawal_payment_time }
    specify { expect(subject.disbursed).to eq false }
  end

  describe "has a withdrawal_payment" do
    subject { withdrawal_payment }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq(-80000) }
    specify { expect(subject.fee_total).to eq(-1500) }
    specify { expect(subject.kind).to eq "Dispute" }
    specify { expect(subject.nonprofit).to eq supporter.nonprofit }
    specify { expect(subject.date).to eq dispute_withdrawal_payment_time }
  end

  it "has only added one payment" do
    obj
    expect(Payment.count).to eq 2 # one for charge, one for DisputeTransaction
  end

  it "has only one dispute transaction" do
    obj
    expect(DisputeTransaction.count).to eq 1
  end

  specify { expect(original_payment.refund_total).to eq 80000 }

  let(:valid_events) { [:created, :funds_withdrawn] }
end

RSpec.shared_context :dispute_created_and_withdrawn_in_order_context do
  include_context :dispute_created_and_withdrawn_at_same_time_context
  let(:event_json_created) do
    json = StripeMockHelper.mock_webhook_event("charge.dispute.created")
    StripeMockHelper.stripe_helper.upsert_stripe_object(:dispute, json["data"]["object"])
    json
  end

  let(:json_created) { event_json_created["data"]["object"] }

  let(:json_funds_withdrawn) { event_json_funds_withdrawn["data"]["object"] }

  let(:event_json_funds_withdrawn) do
    json = StripeMockHelper.mock_webhook_event("charge.dispute.funds_withdrawn")
    StripeMockHelper.stripe_helper.upsert_stripe_object(:dispute, json["data"]["object"])
    json
  end

  let!(:charge) {
    force_create(:charge, supporter: supporter,
      stripe_charge_id: "ch_1Y7zzfBCJIIhvMWmSiNWrPAC", nonprofit: nonprofit, payment: force_create(:payment,
        supporter: supporter,
        nonprofit: nonprofit,
        gross_amount: 80000))
  }
end

RSpec.shared_context :dispute_created_and_withdrawn_in_order_specs do
  include_context :dispute_created_and_withdrawn_in_order_context
  include_context :disputes_specs

  it "has status of needs_response" do
    expect(obj.status).to eq "needs_response"
  end

  it "has reason of duplicate" do
    expect(obj.reason).to eq "duplicate"
  end

  it "has 1 balance transactions" do
    expect(obj.balance_transactions.count).to eq 1
  end

  it "has a net_change of -81500" do
    expect(obj.net_change).to eq(-81500)
  end

  it "has an amount of 80000" do
    expect(obj.amount).to eq 80000
  end

  it "has a correct charge id " do
    expect(obj.stripe_charge_id).to eq "ch_1Y7zzfBCJIIhvMWmSiNWrPAC"
  end

  it "has a correct dispute id" do
    expect(obj.stripe_dispute_id).to eq "dp_05RsQX2eZvKYlo2C0FRTGSSA"
  end

  it "has a started_at of dispute_created_time" do
    expect(obj.started_at).to eq dispute_created_time
  end

  describe "dispute" do
    subject { dispute }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq 80000 }
    specify { expect(subject.status).to eq "needs_response" }
    specify { expect(subject.reason).to eq "duplicate" }
    specify { expect(subject.started_at).to eq dispute_created_time }
  end

  it "has one dispute transaction" do
    expect(dispute_transactions.count).to eq 1
  end

  describe "has a withdrawal_transaction" do
    subject { withdrawal_transaction }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq(-80000) }
    specify { expect(subject.fee_total).to eq(-1500) }
    specify { expect(subject.net_amount).to eq(-81500) }
    specify { expect(subject.stripe_transaction_id).to eq "txn_1Y7pdnBCJIIhvMWmJ9KQVpfB" }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.date).to eq dispute_withdrawal_payment_time }
    specify { expect(subject.disbursed).to eq false }
  end

  describe "has a withdrawal_payment" do
    subject { withdrawal_payment }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq(-80000) }
    specify { expect(subject.fee_total).to eq(-1500) }
    specify { expect(subject.kind).to eq "Dispute" }
    specify { expect(subject.nonprofit).to eq supporter.nonprofit }
    specify { expect(subject.date).to eq dispute_withdrawal_payment_time }
  end

  it "has only added one payment" do
    obj
    expect(Payment.count).to eq 2 # one for charge, one for DisputeTransaction
  end

  it "has only one dispute transaction" do
    obj
    expect(DisputeTransaction.count).to eq 1
  end

  specify { expect(original_payment.refund_total).to eq 80000 }

  let(:valid_events) { [:created, :funds_withdrawn] }
end

RSpec.shared_context :dispute_created_withdrawn_and_lost_in_order_context do
  include_context :disputes_context
  let(:event_json_created) do
    json = StripeMockHelper.mock_webhook_event("charge.dispute.created")
    StripeMockHelper.stripe_helper.upsert_stripe_object(:dispute, json["data"]["object"])
    json
  end

  let(:json_created) { event_json_created["data"]["object"] }

  let(:event_json_funds_withdrawn) do
    json = StripeMockHelper.mock_webhook_event("charge.dispute.funds_withdrawn")
    StripeMockHelper.stripe_helper.upsert_stripe_object(:dispute, json["data"]["object"])
    json
  end

  let(:json_funds_withdrawn) { event_json_funds_withdrawn["data"]["object"] }

  let(:event_json_lost) do
    json = StripeMockHelper.mock_webhook_event("charge.dispute.closed-lost")
    StripeMockHelper.stripe_helper.upsert_stripe_object(:dispute, json["data"]["object"])
    json
  end

  let(:json_lost) do
    event_json_lost["data"]["object"]
  end

  let!(:charge) {
    force_create(:charge, supporter: supporter,
      stripe_charge_id: "ch_1Y7zzfBCJIIhvMWmSiNWrPAC", nonprofit: nonprofit, payment: force_create(:payment,
        supporter: supporter,
        nonprofit: nonprofit,
        gross_amount: 80000))
  }
end

RSpec.shared_context :dispute_created_withdrawn_and_lost_in_order_specs do
  include_context :dispute_created_withdrawn_and_lost_in_order_context
  include_context :disputes_specs

  it "has status of lost" do
    expect(obj.status).to eq "lost"
  end

  it "has reason of duplicate" do
    expect(obj.reason).to eq "duplicate"
  end

  it "has 1 balance transactions" do
    expect(obj.balance_transactions.count).to eq 1
  end

  it "has a net_change of -81500" do
    expect(obj.net_change).to eq(-81500)
  end

  it "has an amount of 80000" do
    expect(obj.amount).to eq 80000
  end

  it "has a correct charge id" do
    expect(obj.stripe_charge_id).to eq "ch_1Y7zzfBCJIIhvMWmSiNWrPAC"
  end

  it "has a correct dispute id" do
    expect(obj.stripe_dispute_id).to eq "dp_05RsQX2eZvKYlo2C0FRTGSSA"
  end

  it "has a started_at of dispute_created_time" do
    expect(obj.started_at).to eq dispute_created_time
  end

  describe "dispute" do
    subject { dispute }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq 80000 }
    specify { expect(subject.status).to eq "lost" }
    specify { expect(subject.reason).to eq "duplicate" }
    specify { expect(subject.started_at).to eq dispute_created_time }
  end

  it "has 1 dispute transactions" do
    expect(dispute_transactions.count).to eq 1
  end

  describe "has a withdrawal_transaction" do
    subject { withdrawal_transaction }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq(-80000) }
    specify { expect(subject.fee_total).to eq(-1500) }
    specify { expect(subject.stripe_transaction_id).to eq "txn_1Y7pdnBCJIIhvMWmJ9KQVpfB" }
    specify { expect(subject.date).to eq dispute_withdrawal_payment_time }
    specify { expect(subject.disbursed).to eq false }
  end

  describe "has a withdrawal_payment" do
    subject { withdrawal_payment }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq(-80000) }
    specify { expect(subject.fee_total).to eq(-1500) }
    specify { expect(subject.net_amount).to eq(-81500) }
    specify { expect(subject.kind).to eq "Dispute" }
    specify { expect(subject.nonprofit).to eq supporter.nonprofit }
    specify { expect(subject.date).to eq dispute_withdrawal_payment_time }
  end

  it "has no reinstated transaction" do
    expect(reinstated_transaction).to be_nil
  end

  specify { expect(original_payment.refund_total).to eq 80000 }

  let(:valid_events) { [:created, :funds_withdrawn, :lost] }
end

RSpec.shared_context :dispute_created_with_withdrawn_and_lost_in_order_context do
  include_context :dispute_created_withdrawn_and_lost_in_order_context

  let(:event_json_created) do
    json = StripeMockHelper.mock_webhook_event("charge.dispute.created-with-one-withdrawn")
    StripeMockHelper.stripe_helper.upsert_stripe_object(:dispute, json["data"]["object"])
    json
  end
end

RSpec.shared_context :dispute_created_with_withdrawn_and_lost_in_order_specs do
  include_context :dispute_created_with_withdrawn_and_lost_in_order_context
  include_context :disputes_specs

  it "has status of lost" do
    expect(obj.status).to eq "lost"
  end

  it "has reason of duplicate" do
    expect(obj.reason).to eq "duplicate"
  end

  it "has 1 balance transactions" do
    expect(obj.balance_transactions.count).to eq 1
  end

  it "has a net_change of -81500" do
    expect(obj.net_change).to eq(-81500)
  end

  it "has an amount of 80000" do
    expect(obj.amount).to eq 80000
  end

  it "has a correct charge id" do
    expect(obj.stripe_charge_id).to eq "ch_1Y7zzfBCJIIhvMWmSiNWrPAC"
  end

  it "has a correct dispute id" do
    expect(obj.stripe_dispute_id).to eq "dp_05RsQX2eZvKYlo2C0FRTGSSA"
  end

  it "has a started_at of dispute_created_time" do
    expect(obj.started_at).to eq dispute_created_time
  end

  describe "dispute" do
    subject { dispute }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq 80000 }
    specify { expect(subject.status).to eq "lost" }
    specify { expect(subject.reason).to eq "duplicate" }
    specify { expect(subject.started_at).to eq dispute_created_time }
  end

  it "has 1 dispute transactions" do
    expect(dispute_transactions.count).to eq 1
  end

  describe "has a withdrawal_transaction" do
    subject { withdrawal_transaction }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq(-80000) }
    specify { expect(subject.fee_total).to eq(-1500) }
    specify { expect(subject.stripe_transaction_id).to eq "txn_1Y7pdnBCJIIhvMWmJ9KQVpfB" }
    specify { expect(subject.date).to eq dispute_withdrawal_payment_time }
    specify { expect(subject.disbursed).to eq false }
  end

  describe "has a withdrawal_payment" do
    subject { withdrawal_payment }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq(-80000) }
    specify { expect(subject.fee_total).to eq(-1500) }
    specify { expect(subject.net_amount).to eq(-81500) }
    specify { expect(subject.kind).to eq "Dispute" }
    specify { expect(subject.nonprofit).to eq supporter.nonprofit }
    specify { expect(subject.date).to eq dispute_withdrawal_payment_time }
  end

  it "has no reinstated transaction" do
    expect(reinstated_transaction).to be_nil
  end

  specify { expect(original_payment.refund_total).to eq 80000 }

  let(:valid_events) { [:created, :funds_withdrawn, :lost] }
end

RSpec.shared_context :dispute_lost_created_and_funds_withdrawn_at_same_time_context do
  include_context :disputes_context
  let(:event_json_created) do
    json = StripeMockHelper.mock_webhook_event("charge.dispute.created")
    json
  end

  let(:json_created) { event_json_created["data"]["object"] }

  let(:event_json_funds_withdrawn) do
    json = StripeMockHelper.mock_webhook_event("charge.dispute.funds_withdrawn")
    json
  end

  let(:json_funds_withdrawn) { event_json_funds_withdrawn["data"]["object"] }

  let(:event_json_lost) do
    json = StripeMockHelper.mock_webhook_event("charge.dispute.closed-lost")
    StripeMockHelper.stripe_helper.upsert_stripe_object(:dispute, json["data"]["object"])
    json
  end

  let(:json_lost) do
    event_json_lost["data"]["object"]
  end

  let!(:charge) {
    force_create(:charge, supporter: supporter,
      stripe_charge_id: "ch_1Y7zzfBCJIIhvMWmSiNWrPAC", nonprofit: nonprofit, payment: force_create(:payment,
        supporter: supporter,
        nonprofit: nonprofit,
        gross_amount: 80000))
  }

  let(:event_json_created) do
    json = StripeMockHelper.mock_webhook_event("charge.dispute.created-with-one-withdrawn")
    json
  end
end

RSpec.shared_context :dispute_lost_created_and_funds_withdrawn_at_same_time_spec do
  include_context :dispute_lost_created_and_funds_withdrawn_at_same_time_context
  include_context :disputes_specs

  it "has status of lost" do
    expect(obj.status).to eq "lost"
  end

  it "has reason of duplicate" do
    expect(obj.reason).to eq "duplicate"
  end

  it "has 1 balance transactions" do
    expect(obj.balance_transactions.count).to eq 1
  end

  it "has a net_change of -81500" do
    expect(obj.net_change).to eq(-81500)
  end

  it "has an amount of 80000" do
    expect(obj.amount).to eq 80000
  end

  it "has a correct charge id" do
    expect(obj.stripe_charge_id).to eq "ch_1Y7zzfBCJIIhvMWmSiNWrPAC"
  end

  it "has a correct dispute id" do
    expect(obj.stripe_dispute_id).to eq "dp_05RsQX2eZvKYlo2C0FRTGSSA"
  end

  it "has a started_at of dispute_created_time" do
    expect(obj.started_at).to eq dispute_created_time
  end

  describe "dispute" do
    subject { dispute }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq 80000 }
    specify { expect(subject.status).to eq "lost" }
    specify { expect(subject.reason).to eq "duplicate" }
    specify { expect(subject.started_at).to eq dispute_created_time }
  end

  it "has 1 dispute transactions" do
    expect(dispute_transactions.count).to eq 1
  end

  describe "has a withdrawal_transaction" do
    subject { withdrawal_transaction }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq(-80000) }
    specify { expect(subject.fee_total).to eq(-1500) }
    specify { expect(subject.stripe_transaction_id).to eq "txn_1Y7pdnBCJIIhvMWmJ9KQVpfB" }
    specify { expect(subject.date).to eq dispute_withdrawal_payment_time }
    specify { expect(subject.disbursed).to eq false }
  end

  describe "has a withdrawal_payment" do
    subject { withdrawal_payment }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq(-80000) }
    specify { expect(subject.fee_total).to eq(-1500) }
    specify { expect(subject.net_amount).to eq(-81500) }
    specify { expect(subject.kind).to eq "Dispute" }
    specify { expect(subject.nonprofit).to eq supporter.nonprofit }
    specify { expect(subject.date).to eq dispute_withdrawal_payment_time }
  end

  it "has no reinstated transaction" do
    expect(reinstated_transaction).to be_nil
  end

  specify { expect(original_payment.refund_total).to eq 80000 }

  let(:valid_events) { [:created, :funds_withdrawn, :lost] }
end

RSpec.shared_context :__dispute_with_two_partial_disputes_withdrawn_at_same_time_context do
  include_context :disputes_context
  let(:event_json_dispute_partial1) do
    json = StripeMockHelper.mock_webhook_event("charge.dispute.created-with-one-withdrawn--partial1")
    StripeMockHelper.stripe_helper.upsert_stripe_object(:dispute, json["data"]["object"])
    json
  end

  let(:json_partial1) { event_json_dispute_partial1["data"]["object"] }

  let(:event_json_dispute_partial2) do
    json = StripeMockHelper.mock_webhook_event("charge.dispute.created-with-one-withdrawn--partial2")
    StripeMockHelper.stripe_helper.upsert_stripe_object(:dispute, json["data"]["object"])
    json
  end

  let(:json_partial2) { event_json_dispute_partial2["data"]["object"] }

  let!(:charge) {
    force_create(:charge, supporter: supporter,
      stripe_charge_id: "ch_1Y7zzfBCJIIhvMWmSiNWrPAC", nonprofit: nonprofit, payment: force_create(:payment,
        supporter: supporter,
        nonprofit: nonprofit,
        gross_amount: 80000))
  }

  specify { expect(original_payment.refund_total).to eq 70000 }
end

RSpec.shared_context :dispute_with_two_partial_disputes_withdrawn_at_same_time_spec__partial1 do
  include_context :__dispute_with_two_partial_disputes_withdrawn_at_same_time_context
  include_context :disputes_specs

  it "has status of needs_response" do
    expect(obj.status).to eq "needs_response"
  end

  it "has reason of duplicate" do
    expect(obj.reason).to eq "duplicate"
  end

  it "has 1 balance transactions" do
    expect(obj.balance_transactions.count).to eq 1
  end

  it "has a net_change of -41500" do
    expect(obj.net_change).to eq(-41500)
  end

  it "has an amount of 40000" do
    expect(obj.amount).to eq 40000
  end

  it "has a correct charge id" do
    expect(obj.stripe_charge_id).to eq "ch_1Y7zzfBCJIIhvMWmSiNWrPAC"
  end

  it "has a correct dispute id" do
    expect(obj.stripe_dispute_id).to eq "dp_05RsQX2eZvKYlo2C0FRTGSSA"
  end

  it "has a started_at of dispute_created_time" do
    expect(obj.started_at).to eq dispute_created_time__partial1
  end

  describe "dispute" do
    subject { dispute }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq 40000 }
    specify { expect(subject.status).to eq "needs_response" }
    specify { expect(subject.reason).to eq "duplicate" }
    specify { expect(subject.started_at).to eq dispute_created_time__partial1 }
  end

  it "has 1 dispute transactions" do
    expect(dispute_transactions.count).to eq 1
  end

  describe "has a withdrawal_transaction" do
    subject { withdrawal_transaction }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq(-40000) }
    specify { expect(subject.fee_total).to eq(-1500) }
    specify { expect(subject.stripe_transaction_id).to eq "txn_1Y7pdnBCJIIhvMWmJ9KQVpfB" }
    specify { expect(subject.date).to eq dispute_withdrawal_payment_time__partial1 }
    specify { expect(subject.disbursed).to eq false }
  end

  describe "has a withdrawal_payment" do
    subject { withdrawal_payment }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq(-40000) }
    specify { expect(subject.fee_total).to eq(-1500) }
    specify { expect(subject.net_amount).to eq(-41500) }
    specify { expect(subject.kind).to eq "Dispute" }
    specify { expect(subject.nonprofit).to eq supporter.nonprofit }
    specify { expect(subject.date).to eq dispute_withdrawal_payment_time__partial1 }
  end

  it "has no reinstated transaction" do
    expect(reinstated_transaction).to be_nil
  end

  let(:valid_events) { [:created, :funds_withdrawn] }
end

RSpec.shared_context :dispute_with_two_partial_disputes_withdrawn_at_same_time_spec__partial2 do
  include_context :__dispute_with_two_partial_disputes_withdrawn_at_same_time_context
  include_context :disputes_specs

  it "has status of needs_response" do
    expect(obj.status).to eq "needs_response"
  end

  it "has reason of duplicate" do
    expect(obj.reason).to eq "duplicate"
  end

  it "has 1 balance transactions" do
    expect(obj.balance_transactions.count).to eq 1
  end

  it "has a net_change of -31500" do
    expect(obj.net_change).to eq(-31500)
  end

  it "has an amount of 30000" do
    expect(obj.amount).to eq 30000
  end

  it "has a correct charge id" do
    expect(obj.stripe_charge_id).to eq "ch_1Y7zzfBCJIIhvMWmSiNWrPAC"
  end

  it "has a correct dispute id" do
    expect(obj.stripe_dispute_id).to eq "dp_25RsQX2eZvKYlo2C0ZXCVBNM"
  end

  it "has a started_at of dispute_created_time" do
    expect(obj.started_at).to eq dispute_created__partial2
  end

  describe "dispute" do
    subject { dispute }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq 30000 }
    specify { expect(subject.status).to eq "needs_response" }
    specify { expect(subject.reason).to eq "duplicate" }
    specify { expect(subject.started_at).to eq dispute_created__partial2 }
  end

  it "has 1 dispute transactions" do
    expect(dispute_transactions.count).to eq 1
  end

  describe "has a withdrawal_transaction" do
    subject { withdrawal_transaction }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq(-30000) }
    specify { expect(subject.fee_total).to eq(-1500) }
    specify { expect(subject.stripe_transaction_id).to eq "txn_1Y7pdnBCJIIhvMWmJ9KQVpfB" }
    specify { expect(subject.date).to eq dispute_withdrawal_payment_time__partial2 }
    specify { expect(subject.disbursed).to eq false }
  end

  describe "has a withdrawal_payment" do
    subject { withdrawal_payment }
    specify { expect(subject).to be_persisted }
    specify { expect(subject.gross_amount).to eq(-30000) }
    specify { expect(subject.fee_total).to eq(-1500) }
    specify { expect(subject.net_amount).to eq(-31500) }
    specify { expect(subject.kind).to eq "Dispute" }
    specify { expect(subject.nonprofit).to eq supporter.nonprofit }
    specify { expect(subject.date).to eq dispute_withdrawal_payment_time__partial2 }
  end

  it "has no reinstated transaction" do
    expect(reinstated_transaction).to be_nil
  end

  let(:valid_events) { [:created, :funds_withdrawn] }
end

RSpec.shared_context :legacy_dispute_context do
  include_context :disputes_context

  let(:json) do
    dispute
    event_json["data"]["object"]
  end

  let!(:dispute) {
    dispute = force_create(:dispute, stripe_dispute_id: event_json["data"]["object"]["id"],
      is_legacy: true,
      charge_id: "ch_1Y7zzfBCJIIhvMWmSiNWrPAC")
    dispute.dispute_transactions.create(gross_amount: -80000, disbursed: true, payment: force_create(:payment, gross_amount: -80000, fee_total: -1500, net_amount: -81500))
    dispute
  }

  let(:dispute_transactions) { dispute.dispute_transactions }

  # we reload this because we'll get the older version if we don't
  let(:original_payment) {
    obj.dispute.original_payment.reload
    obj.dispute.original_payment
  }

  let(:withdrawal_transaction) { dispute.dispute_transactions.order("date").first }
  let(:withdrawal_payment) { withdrawal_transaction.payment }
  let(:reinstated_transaction) { dispute.dispute_transactions.order("date").second }
  let(:reinstated_payment) { reinstated_transaction.payment }

  let(:event_json) do
    json = StripeMockHelper.mock_webhook_event("charge.dispute.funds_withdrawn")
    StripeMockHelper.stripe_helper.upsert_stripe_object(:dispute, json["data"]["object"])
    json
  end
end

RSpec.shared_context :legacy_dispute_specs do
  include_context :legacy_dispute_context
  include_context :disputes_specs
  it "has no Dispute.activities" do
    dispute.reload
    expect(dispute.activities).to be_empty
  end

  let(:valid_events) { [] }
end
