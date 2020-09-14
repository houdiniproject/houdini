# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe InsertRefunds do
  include_context :shared_donation_charge_context
	describe ".modern_refund" do
		context 'when valid' do
      describe 'after switchover' do
        
        RSpec.shared_context :modern_refund_shared do
          before(:each) do
            stub_const("FEE_SWITCHOVER_TIME", Time.now - 1.day)
            expect_job_queued.with JobTypes::RefundCreatedJob, instance_of(Refund)
          end
  
          let(:original_payment) { force_create(:payment, 
            gross_amount:10000,
            refund_total: beginning_refund_total 
            )
          }
  
          let(:charge) { force_create(:charge,
            amount: 10000,
            stripe_charge_id: 'ch_test',
            payment_id: original_payment.id,
            nonprofit_id: nonprofit.id,
            supporter_id: supporter.id 
          )}
  
          let(:reason) { 'duplicate'}
          let(:comment) {'comment'}
         
          let(:stripe_app_fee_refund) {  Stripe::ApplicationFeeRefund.construct_from({amount: amount_of_fees_to_refund, id: 'app_fee_refund_1'})}
          let(:stripe_refund) { Stripe::Refund.construct_from({id: 'refund_1'})}
          let(:perform_stripe_refund_result) do
           {stripe_refund: stripe_refund, stripe_app_fee_refund:stripe_app_fee_refund}
          end

          let(:refund) { Refund.last}
          let(:refund_payment) { refund.payment}
          let(:misc_refund_info) { refund.misc_refund_info}

          before(:each) do
            expect(InsertRefunds).to receive(:perform_stripe_refund).with(
              nonprofit.id, {
                'amount' => amount_to_refund,
                'charge'=> charge.stripe_charge_id,
                'reason' => reason
              }).and_return(perform_stripe_refund_result)
            expect(InsertActivities).to receive(:for_refunds)
          end

          let!(:modern_refund_call) do 
            InsertRefunds.modern_refund(charge.attributes.to_h.with_indifferent_access, {
              amount: amount_to_refund,
              comment: comment,
              reason: reason
          }.with_indifferent_access) 
          end

          it 'has an accurate refund_payment' do
            expect(refund_payment.gross_amount).to eq -amount_to_refund 
            expect(refund_payment.fee_total).to eq amount_of_fees_to_refund
            expect(refund_payment.net_amount).to eq -(amount_to_refund) + amount_of_fees_to_refund
            expect(refund_payment.kind).to eq 'Refund'
          end

          it 'has an accurate original_payment' do
            original_payment.reload

            expect(original_payment.refund_total).to eq ending_refund_total
          end

          it 'has an accurate refund' do
            expect(refund.amount).to eq amount_to_refund
            expect(refund.comment).to eq comment
            expect(refund.reason).to eq reason
          end

          it 'has an accurate misc_refund_info' do
            expect(misc_refund_info.is_modern).to eq true
            if amount_of_fees_to_refund > 0
              expect(misc_refund_info.stripe_application_fee_refund_id).to eq stripe_app_fee_refund.id
            else
              expect(misc_refund_info.stripe_application_fee_refund_id).to be_nil
            end
          end
        end
        

        describe 'full refund from zero' do 
          let(:beginning_refund_total) { 0}
          let(:amount_to_refund) { 10000}
          let(:amount_of_fees_to_refund) { 200 }
          let(:ending_refund_total) { 10000 }
  
          include_context :modern_refund_shared
        end

        describe 'partial refund' do 
          let(:beginning_refund_total) { 5000}
          let(:ending_refund_total) { 10000}
          let(:amount_to_refund) { 5000}
          let(:amount_of_fees_to_refund) { 200 }

          include_context :modern_refund_shared
        end


        describe 'refund 1 cent but make sure not to refund any fees becuase theyre all refunded' do 
          let(:beginning_refund_total) { 9999}
          let(:ending_refund_total) { 10000}
          let(:amount_to_refund) { 1}
          let(:amount_of_fees_to_refund) { 0 }
          
          include_context :modern_refund_shared do
            # we don't have an app fee refund when there's not fees to refund
            let(:stripe_app_fee_refund) { nil}
          end
        end
      end
    end
  end
  
  describe '.calculate_application_fee_to_refund' do
    describe 'after switchover' do 
      before(:each) do 
        stub_const("FEE_SWITCHOVER_TIME", Time.now - 1.day)
        billing_subscription
      end

      RSpec.shared_context :different_types_of_refunds do 
        describe 'full refund' do
          # a little hacky but it works
          let(:application_fee) { Stripe::ApplicationFee.construct_from({amount_refunded: 0, id: 'app_fee_1', amount: full_application_fee})}
          let(:charge) { Stripe::Charge.construct_from({id: 'charge_id_1', amount: 10000, source: card, application_fee: 'app_fee_1', created: Time.now, refunded: true})}
          let(:refund) { Stripe::Refund.construct_from({amount: 10000, charge: charge.id})}
          let(:result) { InsertRefunds.calculate_application_fee_to_refund(nonprofit.id, refund, charge, application_fee)}
          it 'returns our fee of 390' do
            expect(result).to eq 390
          end
        end

        describe 'half refund' do 
          let(:application_fee) { Stripe::ApplicationFee.construct_from({amount_refunded: 0, id: 'app_fee_1', amount: full_application_fee})}
          let(:charge) { Stripe::Charge.construct_from({id: 'charge_id_1', amount: 10000, source: card, application_fee: 'app_fee_1', created: Time.now, refunded: false})}
          let(:refund) { Stripe::Refund.construct_from({amount: 5000, charge: charge.id})}
          let(:result) { InsertRefunds.calculate_application_fee_to_refund(nonprofit.id, refund, charge, application_fee)}
          it 'returns our fee of 195' do
            expect(result).to eq 195
          end
        end

        describe 'partial refund when part already refunded' do 
          let(:application_fee) { Stripe::ApplicationFee.construct_from({amount_refunded: 195, id: 'app_fee_1', amount: full_application_fee})}
          let(:charge) { Stripe::Charge.construct_from({id: 'charge_id_1', amount: 10000, source: card, application_fee: 'app_fee_1', created: Time.now, refunded: false})}
          let(:refund) { Stripe::Refund.construct_from({amount: 3000, charge: charge.id})}
          let(:result) { InsertRefunds.calculate_application_fee_to_refund(nonprofit.id, refund, charge, application_fee)}
          it 'returns our fee of 117' do
            expect(result).to eq 117
          end
        end


        describe 'partial refund finishing off partial refund' do 
          let(:application_fee) { Stripe::ApplicationFee.construct_from({amount_refunded: 389, id: 'app_fee_1', amount: full_application_fee})}
          let(:charge) { Stripe::Charge.construct_from({id: 'charge_id_1', amount: 10000, source: card, application_fee: 'app_fee_1', created: Time.now, refunded: true})}
          let(:refund) { Stripe::Refund.construct_from({amount: 1, charge: charge.id})}
          let(:result) { InsertRefunds.calculate_application_fee_to_refund(nonprofit.id, refund, charge, application_fee)}
          it 'returns our fee of 1' do
            expect(result).to eq 1
          end
        end


        describe 'partial refund doesnt refund too much of platform fee' do 
          # we've refunded this all so we can't refund any more!
          let(:application_fee) { Stripe::ApplicationFee.construct_from({amount_refunded: 390, id: 'app_fee_1', amount: full_application_fee})}
          let(:charge) { Stripe::Charge.construct_from({id: 'charge_id_1', amount: 10000, source: card, application_fee: 'app_fee_1', created: Time.now, refunded: true})}
          let(:refund) { Stripe::Refund.construct_from({amount: 1, charge: charge.id})}
          let(:result) { InsertRefunds.calculate_application_fee_to_refund(nonprofit.id, refund, charge, application_fee)}
          it 'returns our fee of 0' do
            expect(result).to eq 0
          end
        end
      end
      describe 'local visa' do

        let(:full_application_fee) { 640}
        
        let(:card) { Stripe::Card.construct_from({brand: 'Visa', country: "US"})}
        include_context :different_types_of_refunds
      end

      describe 'foreign visa' do
        let(:full_application_fee) { 740}
        
        let(:card) { Stripe::Card.construct_from({brand: 'Visa', country: "UK"})}
        include_context :different_types_of_refunds
      end

      describe 'local amex' do
        let(:full_application_fee) { 740}
        
        let(:card) { Stripe::Card.construct_from({brand: 'American Express', country: "US"})}
        include_context :different_types_of_refunds
      end

      describe 'foreign amex' do 
        let(:full_application_fee) { 840}
        
        let(:card) { Stripe::Card.construct_from({brand: 'American Express', country: "UK"})}
        include_context :different_types_of_refunds
      end
    end
  end
end
