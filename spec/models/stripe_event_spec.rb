# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe StripeEvent, :type => :model do
  around(:each) do |example|
    StripeMock.start
    Timecop.freeze(Date.new(2021, 5, 4)) do
      example.run
    end
    StripeMock.stop
  end
  let(:stripe_helper) { StripeMock.create_test_helper }

  describe "stripe_account.updated" do 
    let(:nonprofit_verification_process_status) do
      create(:nonprofit_verification_process_status,
      stripe_account_id: 'acct_1G8Y94CcxDUSisy4',
      started_at: DateTime.now - 1.minutes,
      email_to_send_guid: fake_send_guid
    )
    end

    let(:fake_send_guid) {'FAKE_GUID'}
    let(:event_object_for_pending) {
      create(:stripe_event,
        event_id:"test_evt_1", 
        event_time: DateTime.now - 1.minutes, 
        object_id: 'acct_1G8Y94CcxDUSisy4')
    }

    let(:later_event_object) {
      create(:stripe_event,
        event_id:"test_evt_new", 
        event_time: DateTime.now + 1.minutes, 
        object_id: 'acct_1G8Y94CcxDUSisy4')
    }

    let(:previous_event_object) {
      create(:stripe_event,
        event_id:"test_evt_old", 
        event_time: DateTime.now - 1.minutes, 
        object_id: 'acct_1G8Y94CcxDUSisy4')
    }

    it 'skips processing already processed events' do
      event_object_for_pending
      StripeEvent.handle(StripeMock.mock_webhook_event('account.updated.with-pending'))
      expect(StripeAccount.count).to eq 0
    end

    it 'skips processing weve already processed a newer event for object' do
      later_event_object
      StripeEvent.handle(StripeMock.mock_webhook_event('account.updated.with-pending'))
      expect(StripeAccount.count).to eq 0
    end

    describe 'new StripeAccount' do
      describe 'handles unverified' do
        let(:event_json) { StripeMock.mock_webhook_event('account.updated.with-unverified')}

        let(:last_event) { StripeEvent.last}
        let(:last_account) { StripeAccount.last}
        
        describe 'when in verification process' do
          before(:each) do
            nonprofit_verification_process_status
            previous_event_object
            sam = double(StripeAccountMailer)
            expect(sam).to receive(:conditionally_send_not_completed)
            expect(StripeAccountMailer).to receive(:delay).with(run_at: DateTime.now + 5.minutes).and_return(sam)
            StripeEvent.handle(event_json)
          end

          it 'saved the event' do
            expect(last_event.event_id).to eq 'test_evt_1'
            expect(last_event.object_id).to eq 'acct_1G8Y94CcxDUSisy4'
            expect(last_event.event_time).to eq Time.now
          end

          it 'saves StripeAccount' do 
            expect(last_account.verification_status).to be :unverified
          end

          it 'updates the NonprofitVerificationProcessStatus' do
            nonprofit_verification_process_status.reload
            expect(nonprofit_verification_process_status.email_to_send_guid).to_not eq fake_send_guid
          end
        end

        describe 'when not in verification process' do
          before(:each) do
            previous_event_object
            expect(StripeAccountMailer).to_not receive(:delay)
            StripeEvent.handle(event_json)
          end

          it 'saved the event' do
            expect(last_event.event_id).to eq 'test_evt_1'
            expect(last_event.object_id).to eq 'acct_1G8Y94CcxDUSisy4'
            expect(last_event.event_time).to eq Time.now
          end

          it 'saves StripeAccount' do 
            expect(last_account.verification_status).to be :unverified
          end

          it 'doesnt add a NonprofitVerificationProcessStatus' do
            expect(NonprofitVerificationProcessStatus.count).to eq 0
          end
        end
      end

      describe 'handles temporarily_verified' do
        let(:event_json) { StripeMock.mock_webhook_event('account.updated.with-temporarily_verified')}

        let(:last_event) { StripeEvent.last}
        let(:last_account) { StripeAccount.last}
        
        describe 'when in verification process' do
          before(:each) do
            nonprofit_verification_process_status
            previous_event_object
            sam = double(StripeAccountMailer)
            expect(sam).to receive(:conditionally_send_verified)
            expect(StripeAccountMailer).to receive(:delay).and_return(sam)
            StripeEvent.handle(event_json)
          end

          it 'saved the event' do
            expect(last_event.event_id).to eq 'test_evt_1'
            expect(last_event.object_id).to eq 'acct_1G8Y94CcxDUSisy4'
            expect(last_event.event_time).to eq Time.now
          end

          it 'saves StripeAccount' do 
            expect(last_account.verification_status).to be :temporarily_verified
          end

          it 'updates the NonprofitVerificationProcessStatus' do
            expect {nonprofit_verification_process_status.reload}.to raise_error ActiveRecord::RecordNotFound
          end
        end

        describe 'when not in verification process' do
          before(:each) do
            previous_event_object
            expect(StripeAccountMailer).to_not receive(:delay)
            StripeEvent.handle(event_json)
          end

          it 'saved the event' do
            expect(last_event.event_id).to eq 'test_evt_1'
            expect(last_event.object_id).to eq 'acct_1G8Y94CcxDUSisy4'
            expect(last_event.event_time).to eq Time.now
          end

          it 'saves StripeAccount' do 
            expect(last_account.verification_status).to eq :temporarily_verified
          end

          it 'doesnt add a NonprofitVerificationProcessStatus' do
            expect(NonprofitVerificationProcessStatus.count).to eq 0
          end
        end
      end

      describe 'handles verified' do
        let(:event_json) { StripeMock.mock_webhook_event('account.updated.with-verified')}
        let(:last_event) { StripeEvent.last}
        let(:last_account) { StripeAccount.last}
        
        describe 'when in verification process' do
          before(:each) do
            nonprofit_verification_process_status
            previous_event_object
            sam = double(StripeAccountMailer)
            expect(sam).to receive(:conditionally_send_verified)
            expect(StripeAccountMailer).to receive(:delay).and_return(sam)
            StripeEvent.handle(event_json)
          end
          
          it 'saved the event' do
            expect(last_event.event_id).to eq 'test_evt_1'
            expect(last_event.object_id).to eq 'acct_1G8Y94CcxDUSisy4'
            expect(last_event.event_time).to eq Time.now
          end

          it 'saves StripeAccount' do 
            expect(last_account.verification_status).to be :verified
          end

          it 'deleted the NonprofitVerificationProcessStatus' do
            expect {nonprofit_verification_process_status.reload}.to raise_error ActiveRecord::RecordNotFound
          end
        end

        describe 'when not in verification process' do
          before(:each) do
            previous_event_object
            expect(StripeAccountMailer).to_not receive(:delay)
            StripeEvent.handle(event_json)
          end
          
          it 'saved the event' do
            expect(last_event.event_id).to eq 'test_evt_1'
            expect(last_event.object_id).to eq 'acct_1G8Y94CcxDUSisy4'
            expect(last_event.event_time).to eq Time.now
          end

          it 'saves StripeAccount' do 
            expect(last_account.verification_status).to be :verified
          end

          it 'doesnt add a NonprofitVerificationProcessStatus' do
            expect(NonprofitVerificationProcessStatus.count).to eq 0
          end
        end
      end
    end


    describe 'old StripeAccount' do 
      describe 'handles unverified' do
        let(:event_json) { StripeMock.mock_webhook_event('account.updated.with-unverified')}
        let(:last_event) { StripeEvent.last}
        let(:last_account) { create(:stripe_account, stripe_account_id:'acct_1G8Y94CcxDUSisy4', currently_due: JSON::generate(['something']))}

        describe 'when in verification process' do
          before(:each) do
            nonprofit_verification_process_status
            last_account
            previous_event_object
            sam = double(StripeAccountMailer)
            expect(sam).to receive(:conditionally_send_not_completed)
            expect(StripeAccountMailer).to receive(:delay).with(run_at: DateTime.now + 5.minutes).and_return(sam)
            StripeEvent.handle(event_json)
          end

          it 'saved the event' do
            expect(last_event.event_id).to eq 'test_evt_1'
            expect(last_event.object_id).to eq 'acct_1G8Y94CcxDUSisy4'
            expect(last_event.event_time).to eq Time.now
          end

          it 'saves StripeAccount' do 
            last_account.reload
            expect(last_account.verification_status).to be :unverified
          end

          it 'updates the NonprofitVerificationProcessStatus' do
            
            nonprofit_verification_process_status.reload
            expect(nonprofit_verification_process_status.email_to_send_guid).to_not eq fake_send_guid
          end
        end

        describe 'when not in verification process' do
          before(:each) do
            last_account
            last_account.currently_due = JSON::generate(['something'])
            last_account.save!
            previous_event_object
            # byebug
            expect(StripeAccountMailer).to_not receive(:delay)
            StripeEvent.handle(event_json)
          end

          it 'saved the event' do
            expect(last_event.event_id).to eq 'test_evt_1'
            expect(last_event.object_id).to eq 'acct_1G8Y94CcxDUSisy4'
            expect(last_event.event_time).to eq Time.now
          end

          it 'saves StripeAccount' do 
            last_account.reload
            expect(last_account.verification_status).to be :unverified
          end

          it 'doesnt add a NonprofitVerificationProcessStatus' do
            expect(NonprofitVerificationProcessStatus.count).to eq 0
          end
        end
      end

      describe 'handles from pending to unverified' do
        let(:event_json) { StripeMock.mock_webhook_event('account.updated.with-unverified')}
        let(:last_event) { StripeEvent.last}
        let(:last_account) { create(:stripe_account, stripe_account_id:'acct_1G8Y94CcxDUSisy4')}

        describe 'when in verification process' do
          before(:each) do
            nonprofit_verification_process_status
            last_account
            last_account.pending_verification = JSON::generate(['exciting'])
            last_account.save!
            previous_event_object
            sam = double(StripeAccountMailer)
            expect(sam).to receive(:conditionally_send_more_info_needed)
            expect(StripeAccountMailer).to receive(:delay).with(run_at: DateTime.now + 5.minutes).and_return(sam)
            expect(last_account.verification_status).to eq :pending
            StripeEvent.handle(event_json)
          end

      
      
          it 'saved the event' do
            expect(last_event.event_id).to eq 'test_evt_1'
            expect(last_event.object_id).to eq 'acct_1G8Y94CcxDUSisy4'
            expect(last_event.event_time).to eq Time.now
          end

          it 'saves StripeAccount' do 
            last_account.reload
            expect(last_account.verification_status).to be :unverified
          end

          it 'updates the NonprofitVerificationProcessStatus' do
            
            nonprofit_verification_process_status.reload
            expect(nonprofit_verification_process_status.email_to_send_guid).to_not eq fake_send_guid
          end
        end

        describe 'when not in verification process' do
          before(:each) do
            last_account
            last_account.pending_verification = JSON::generate(['exciting'])
            last_account.save!
            previous_event_object
            expect(StripeAccountMailer).to_not receive(:delay)
            expect(last_account.verification_status).to eq :pending
            StripeEvent.handle(event_json)
          end

      
      
          it 'saved the event' do
            expect(last_event.event_id).to eq 'test_evt_1'
            expect(last_event.object_id).to eq 'acct_1G8Y94CcxDUSisy4'
            expect(last_event.event_time).to eq Time.now
          end

          it 'saves StripeAccount' do 
            last_account.reload
            expect(last_account.verification_status).to be :unverified
          end

          it 'doesnt add a NonprofitVerificationProcessStatus' do
            expect(NonprofitVerificationProcessStatus.count).to eq 0
          end
        end
      end

      describe 'handles temporarily_verified' do
        let(:event_json) { StripeMock.mock_webhook_event('account.updated.with-temporarily_verified')}

        let(:last_event) { StripeEvent.last}
        let(:last_account) { create(:stripe_account, stripe_account_id:'acct_1G8Y94CcxDUSisy4')}
        
        describe 'when in verification process' do
          before(:each) do
            nonprofit_verification_process_status
            last_account
            previous_event_object
            sam = double(StripeAccountMailer)
            expect(sam).to receive(:conditionally_send_verified)
            expect(StripeAccountMailer).to receive(:delay).and_return(sam)
            StripeEvent.handle(event_json)
            last_account.reload
          end

          it 'saved the event' do
            expect(last_event.event_id).to eq 'test_evt_1'
            expect(last_event.object_id).to eq 'acct_1G8Y94CcxDUSisy4'
            expect(last_event.event_time).to eq Time.now
          end

          it 'saves StripeAccount' do 
            expect(last_account.verification_status).to eq :temporarily_verified
          end

          it 'updates the NonprofitVerificationProcessStatus' do
            expect {nonprofit_verification_process_status.reload}.to raise_error ActiveRecord::RecordNotFound
          end
        end
        
        describe 'when not in verification process' do
          before(:each) do
            previous_event_object
            last_account
            expect(StripeAccountMailer).to_not receive(:delay)
            StripeEvent.handle(event_json)
            last_account.reload
          end

          it 'saved the event' do
            expect(last_event.event_id).to eq 'test_evt_1'
            expect(last_event.object_id).to eq 'acct_1G8Y94CcxDUSisy4'
            expect(last_event.event_time).to eq Time.now
          end

          it 'saves StripeAccount' do 
            expect(last_account.verification_status).to eq :temporarily_verified
          end

          it 'doesnt add a NonprofitVerificationProcessStatus' do
            expect(NonprofitVerificationProcessStatus.count).to eq 0
          end
        end
      end

      describe 'handles verified' do
        let(:event_json) { StripeMock.mock_webhook_event('account.updated.with-verified')}
        let(:last_event) { StripeEvent.last}
        let(:last_account) { create(:stripe_account, stripe_account_id:'acct_1G8Y94CcxDUSisy4', currently_due: ['something'])}
        describe 'when in verification process' do
          before(:each) do
            nonprofit_verification_process_status
            last_account
            previous_event_object
            sam = double(StripeAccountMailer)
            expect(sam).to receive(:conditionally_send_verified)
            expect(StripeAccountMailer).to receive(:delay).and_return(sam)
            StripeEvent.handle(event_json)
            
          end
          
          it 'saved the event' do
            expect(last_event.event_id).to eq 'test_evt_1'
            expect(last_event.object_id).to eq 'acct_1G8Y94CcxDUSisy4'
            expect(last_event.event_time).to eq Time.now
          end

          it 'saves StripeAccount' do 
            expect(last_account.verification_status).to be :verified
          end

          it 'deleted the NonprofitVerificationProcessStatus' do
            expect {nonprofit_verification_process_status.reload}.to raise_error ActiveRecord::RecordNotFound
          end
        end

        describe 'when not in verification process' do
          before(:each) do
            last_account
            previous_event_object
            expect(StripeAccountMailer).to_not receive(:delay)
            StripeEvent.handle(event_json)
          end
          
          it 'saved the event' do
            expect(last_event.event_id).to eq 'test_evt_1'
            expect(last_event.object_id).to eq 'acct_1G8Y94CcxDUSisy4'
            expect(last_event.event_time).to eq Time.now
          end

          it 'saves StripeAccount' do 
            expect(last_account.verification_status).to be :verified
          end

          it 'doesnt add a NonprofitVerificationProcessStatus' do
            expect(NonprofitVerificationProcessStatus.count).to eq 0
          end
        end
      end

      describe 'handles pending' do
        let(:event_json) { StripeMock.mock_webhook_event('account.updated.with-pending')}
        let(:last_event) { StripeEvent.last}
        let(:last_account) { create(:stripe_account, stripe_account_id:'acct_1G8Y94CcxDUSisy4', currently_due: ['something'])}
        describe 'when in verification process' do
          before(:each) do
            nonprofit_verification_process_status
            last_account
            previous_event_object
            sam = double(StripeAccountMailer)
            expect(sam).to receive(:conditionally_send_not_completed)
            expect(StripeAccountMailer).to receive(:delay).and_return(sam)
            StripeEvent.handle(event_json)
            
          end
          
          it 'saved the event' do
            expect(last_event.event_id).to eq 'test_evt_1'
            expect(last_event.object_id).to eq 'acct_1G8Y94CcxDUSisy4'
            expect(last_event.event_time).to eq Time.now
          end

          it 'saves StripeAccount' do
            last_account.reload
            expect(last_account.verification_status).to be :pending
          end

          it 'updates the NonprofitVerificationProcessStatus' do
            
            nonprofit_verification_process_status.reload
            expect(nonprofit_verification_process_status.email_to_send_guid).to_not eq fake_send_guid
          end
        end
        
        describe 'when not in verification process' do
          before(:each) do
            last_account
            previous_event_object
            expect(StripeAccountMailer).to_not receive(:delay)
            StripeEvent.handle(event_json)
          end
          
          it 'saved the event' do
            expect(last_event.event_id).to eq 'test_evt_1'
            expect(last_event.object_id).to eq 'acct_1G8Y94CcxDUSisy4'
            expect(last_event.event_time).to eq Time.now
          end

          it 'saves StripeAccount' do
            last_account.reload
            expect(last_account.verification_status).to be :pending
          end

          it 'doesnt add a NonprofitVerificationProcessStatus' do
            expect(NonprofitVerificationProcessStatus.count).to eq 0
          end
        end
      end

      describe 'handles verified to unverified' do
        let(:deadline) { Time.utc(2020, 2, 28, 22, 27, 35)}
        let(:event_json) { StripeMock.mock_webhook_event('account.updated.with-unverified-from-verified')}
        let(:last_event) { StripeEvent.last}
        let(:last_account) { create(:stripe_account, stripe_account_id:'acct_1G8Y94CcxDUSisy4')}

        describe 'when not in verification process' do
          before(:each) do
            last_account
            previous_event_object
            sam = double(StripeAccountMailer)
            expect(sam).to receive(:conditionally_send_no_longer_verified).with(last_account)
            expect(StripeAccountMailer).to receive(:delay).and_return(sam)
            expect(last_account.verification_status).to eq :verified
            StripeEvent.handle(event_json)
          end

          it 'saved the event' do
            expect(last_event.event_id).to eq 'test_evt_1'
            expect(last_event.object_id).to eq 'acct_1G8Y94CcxDUSisy4'
            expect(last_event.event_time).to eq Time.now
          end

          it 'saves StripeAccount' do 
            last_account.reload
            expect(last_account.verification_status).to eq :unverified
          end

          it 'doesnt add a NonprofitVerificationProcessStatus' do
            expect(NonprofitVerificationProcessStatus.count).to eq 0
          end
        end
      end
    end
  end

  describe 'charge.dispute.*' do 
    describe "dispute.created" do
      include_context :dispute_created_specs
      let(:obj) {
        StripeEvent.process_dispute(event_json)
        StripeDispute.where('stripe_dispute_id = ?', json['id']).first
      }
    end
  
    describe "dispute.funds_withdrawn" do
      include_context :dispute_funds_withdrawn_specs
  
      let(:obj) do
        StripeEvent.process_dispute(event_json)
        StripeDispute.where('stripe_dispute_id = ?', json['id']).first
      end
    end
  
    describe "dispute.created AND funds_withdrawn at sametime" do 
      let(:json_created) do
        StripeMock.mock_webhook_event('charge.dispute.created-with-one-withdrawn')
      end
  
      let(:json_funds_withdrawn) do
        json = StripeMock.mock_webhook_event('charge.dispute.funds_withdrawn')
        stripe_helper.upsert_stripe_object(:dispute, json['data']['object'])
        json
      end
  
      let(:supporter) { force_create(:supporter)}
      let!(:charge) { force_create(:charge, supporter: supporter, stripe_charge_id: 'ch_1Y7zzfBCJIIhvMWmSiNWrPAC', nonprofit: supporter.nonprofit)}
  
      let(:obj) {
        json_funds_withdrawn
        StripeEvent.process_dispute(json_created)
        StripeEvent.process_dispute(json_funds_withdrawn)
        StripeDispute.where('stripe_dispute_id = ?', json_funds_withdrawn['data']['object']['id']).first
      }
  
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
        expect(Payment.count).to eq 1
      end
  
      it 'has only one dispute transaction' do 
        obj
        expect(DisputeTransaction.count).to eq 1
      end
  
    end
  
    describe "dispute.funds_reinstated" do
      include_context :dispute_funds_reinstated_specs
      let(:obj) do StripeEvent.process_dispute(event_json)
        StripeDispute.where('stripe_dispute_id = ?', json['id']).first
      end
    end
  
    describe "dispute.closed, status = lost" do
      include_context :dispute_lost_specs
  
      let(:obj) do
        StripeEvent.process_dispute(event_json)
        StripeDispute.where('stripe_dispute_id = ?', json['id']).first
      end
    end
  
    describe "dispute.created -> dispute.funds_withdrawn -> dispute.closed, status = lost " do
      let(:created_json) do
        StripeMock.mock_webhook_event('charge.dispute.created')
        
      end
      let(:withdrawn_json) do
        StripeMock.mock_webhook_event('charge.dispute.funds_withdrawn')
      end
      let(:lost_json) do
        json = StripeMock.mock_webhook_event('charge.dispute.closed-lost')
        stripe_helper.upsert_stripe_object(:dispute, json['data']['object'])
        json
      end
      let(:supporter) { force_create(:supporter)}
      let!(:charge) { force_create(:charge, supporter: supporter, stripe_charge_id: 'ch_1Y7zzfBCJIIhvMWmSiNWrPAC', nonprofit: supporter.nonprofit)}
  
      let(:obj) { 
        lost_json
        StripeEvent.process_dispute(created_json)
        StripeEvent.process_dispute(withdrawn_json)
        StripeEvent.process_dispute(lost_json)
        StripeDispute.where('stripe_dispute_id = ?', lost_json['data']['object']['id']).first
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
  
    describe "dispute.created-with-one-withdrawn -> dispute.funds_withdrawn -> dispute.closed, status = lost " do
      let(:created_json) do
        StripeMock.mock_webhook_event('charge.dispute.created-with-one-withdrawn')
      end
      let(:withdrawn_json) do
        StripeMock.mock_webhook_event('charge.dispute.funds_withdrawn')
      end
      let(:lost_json) do
        json = StripeMock.mock_webhook_event('charge.dispute.closed-lost')
        stripe_helper.upsert_stripe_object(:dispute, json['data']['object'])
        json
      end
      let(:supporter) { force_create(:supporter)}
      let!(:charge) { force_create(:charge, supporter: supporter, stripe_charge_id: 'ch_1Y7zzfBCJIIhvMWmSiNWrPAC', nonprofit: supporter.nonprofit)}
  
      let(:obj) {
        lost_json
        StripeEvent.process_dispute(created_json)
        StripeEvent.process_dispute(withdrawn_json)
        StripeEvent.process_dispute(lost_json)
        StripeDispute.where('stripe_dispute_id = ?', lost_json['data']['object']['id']).first
      }
  
      let(:dispute) { obj.dispute }
      let(:dispute_transactions) { dispute.dispute_transactions }
      let(:withdrawal_transaction) {dispute.dispute_transactions.order("date").first}
      let(:withdrawal_payment) {withdrawal_transaction.payment}
      let(:reinstated_transaction) {dispute.dispute_transactions.order("date").second}
      let(:reinstated_payment) {reinstated_transaction.payment}
  
      it 'has status of lost' do 
        expect(obj.status).to eq 'lost'
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
  
    describe "dispute.closed, status = lost -> dispute.created -> dispute.funds_withdrawn" do
      let(:created_json) do
        StripeMock.mock_webhook_event('charge.dispute.created')
      end
      let(:withdrawn_json) do
        StripeMock.mock_webhook_event('charge.dispute.funds_withdrawn')
      end
      let(:lost_json) do
        json = StripeMock.mock_webhook_event('charge.dispute.closed-lost')
        stripe_helper.upsert_stripe_object(:dispute, json['data']['object'])
        json
      end
      let(:supporter) { force_create(:supporter)}
      let!(:charge) { force_create(:charge, supporter: supporter, stripe_charge_id: 'ch_1Y7zzfBCJIIhvMWmSiNWrPAC', nonprofit: supporter.nonprofit)}
  
      let(:obj) {
        StripeEvent.process_dispute(lost_json)
        StripeEvent.process_dispute(created_json)
        StripeEvent.process_dispute(withdrawn_json)
        StripeDispute.where('stripe_dispute_id = ?', lost_json['data']['object']['id']).first
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
  
    describe "dispute.closed, status = won" do
      include_context :dispute_won_specs
      let(:obj) do
        StripeEvent.process_dispute(event_json)
        StripeDispute.where('stripe_dispute_id = ?', json['id']).first
      end
    end
  end
end
