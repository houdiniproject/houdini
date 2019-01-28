# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe UpdatePayouts do
  describe '.reverse_with_stripe' do
    describe 'param validation' do
      it 'basic param_validation' do
        expect { UpdatePayouts.reverse_with_stripe(nil, nil, nil)}.to(raise_error {|error|
          expect(error).to be_a(ParamValidation::ValidationError)
          expect_validation_errors(error.data, [{key: :payout_id, name: :required},
                                                {key: :payout_id, name: :is_integer},
                                                {key: :status, name: :required},
                                                {key: :status, name: :included_in},
                                                {key: :failure_message, name: :required},
                                                {key: :failure_message, name: :not_blank}])
        })
      end

      it 'reject non-existent payouts' do
        expect { UpdatePayouts.reverse_with_stripe(5555555, "failed", "failure")}.to(raise_error {|error|
          expect(error).to be_a(ParamValidation::ValidationError)
          expect_validation_errors(error.data, [{key: :payout_id}])
        })
      end

      it 'reject payouts with no payments' do
        payout = force_create(:payout)
        expect { UpdatePayouts.reverse_with_stripe(payout.id, "failed", "failure")}.to(raise_error {|error|
          expect(error).to be_a(ArgumentError)
        })
      end


    end

    describe 'validate proper function' do
      let(:payment_to_reverse) { force_create(:payment) }
      let(:payment_to_ignore) { force_create(:payment) }
      let(:payment_to_reverse_2) { force_create(:payment) }
      let(:payment_to_reverse_with_refund) { force_create(:payment)}
      let(:reverse_payment_for_refund) { force_create(:payment)}


      let!(:charges) {[force_create(:charge, payment: payment_to_reverse, status: 'disbursed'),
                       force_create(:charge, payment: payment_to_reverse_2, status: 'disbursed'),
                       force_create(:charge, payment: payment_to_ignore, status: 'disbursed'),
                      force_create(:charge, payment: payment_to_reverse_with_refund, status:'disbursed')
      ]}

      let!(:refunds) { [force_create(:refund, charge: charges.last, payment: reverse_payment_for_refund, disbursed: true)]}


      let(:np) {force_create(:nonprofit)}
      let!(:bank_account) {force_create(:bank_account, nonprofit: np)}
      let!(:payout) {force_create(:payout, status: "paid", failure_message: 'all good',
                                 nonprofit: np, stripe_transfer_id: 'transfer_id', email: 'no one cares', net_amount: 500)}

      let(:bad_status) { 'failed'}
      let(:bad_failure_message) { 'so terrible'}
      let(:available) { 'available'}

      before(:each){
        payout.payments.push(payment_to_reverse)
        payout.payments.push(payment_to_reverse_2)
        payout.payments.push(payment_to_reverse_with_refund)
        payout.payments.push(reverse_payment_for_refund)
        UpdatePayouts.reverse_with_stripe(payout.id, bad_status, bad_failure_message)
        payment_to_reverse.reload
        payment_to_reverse_2.reload
        payment_to_reverse_with_refund.reload
        reverse_payment_for_refund.reload
        payment_to_ignore.reload
      }

      it 'reverses proper payments' do
        expect(payment_to_reverse.charge.status).to eq available
        expect(payment_to_reverse_2.charge.status).to eq available
        expect(payment_to_reverse_with_refund.charge.status).to eq available
      end

      it 'reverses proper refunds' do
        refund = refunds.first
        refund.reload
        expect(refund.disbursed).to eq false
      end

      it 'reverses disputes', pending: 'disputes aren\'t properly modeled to safely do this' do
        fail
      end

      it 'ignores irrelevant payments' do
        expect(payment_to_ignore.charge.status).to eq 'disbursed'
      end

      it 'changes payout status and failure' do
        payout.reload
        expect(payout.status).to eq bad_status
        expect(payout.failure_message).to eq bad_failure_message
      end
    end
  end
end