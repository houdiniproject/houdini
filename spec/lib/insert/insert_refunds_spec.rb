# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe InsertRefunds do
  include_context :shared_donation_charge_context
  describe ".modern_refund" do
    context :modern_refund_shared do
      include_context "common fee scenarios"
      before(:each) do
        expect_job_queued.with JobTypes::RefundCreatedJob, instance_of(Refund)
      end
      SCENARIOS.each do |example|
        context "when charge is #{example[:at]}" do
          context "for #{example[:source]}" do
            example[:refunds].each do |refund_ex|
              context "with following inputs #{refund_ex}" do
                let(:transaction) {
                  Transaction.create(
                    supporter: original_payment.supporter,
                    transaction_assignments: [TransactionAssignment.new(
                      assignable: ModernDonation.new(amount: example[:amount], legacy_donation: original_donation)
                    )],
                    subtransaction: Subtransaction.new(
                      subtransaction_payments: [
                        SubtransactionPayment.new(
                          legacy_payment: charge.payment,
                          paymentable: StripeTransactionCharge.new
                        )
                      ],
                      subtransactable: StripeTransaction.new(
                        amount: example[:amount]
                      )
                    )
                  )
                }

                let(:original_donation) {
                  force_create(:donation, payment: original_payment, amount: example[:amount],
                    supporter: original_payment.supporter,
                    nonprofit: original_payment.nonprofit)
                }

                let(:original_payment) {
                  force_create(:payment,
                    gross_amount: example[:amount],
                    refund_total: beginning_refund_total,
                    net_amount: example[:amount],
                    fee_total: 0,
                    supporter: supporter,
                    nonprofit: nonprofit,
                    date: Time.current)
                }

                let(:charge) {
                  force_create(:charge,
                    amount: 10000,
                    stripe_charge_id: "ch_test",
                    payment_id: original_payment.id,
                    nonprofit_id: nonprofit.id,
                    supporter_id: supporter.id)
                }

                let(:reason) { "duplicate" }
                let(:comment) { "comment" }

                let(:stripe_app_fee_refund) { Stripe::ApplicationFeeRefund.construct_from({amount: amount_of_fees_to_refund, id: "app_fee_refund_1"}) }
                let(:stripe_refund) { Stripe::Refund.construct_from({id: "refund_1"}) }
                let(:perform_stripe_refund_result) do
                  {stripe_refund: stripe_refund, stripe_app_fee_refund: (amount_of_fees_to_refund > 0) ? stripe_app_fee_refund : nil}
                end

                let(:refund) { Refund.last }
                let(:refund_payment) { refund.payment }
                let(:misc_refund_info) { refund.misc_refund_info }

                let(:amount_of_fees_to_refund) { refund_ex[:calculate_application_fee_refund_result] }
                let(:amount_to_refund) { refund_ex[:amount_refunded] }
                let(:beginning_refund_total) { refund_ex[:refunded_already] }
                let(:ending_refund_total) { amount_to_refund + beginning_refund_total }

                before(:each) do
                  expect(InsertRefunds).to receive(:perform_stripe_refund).with(
                    nonprofit_id: nonprofit.id, refund_data: {
                      "amount" => amount_to_refund,
                      "charge" => charge.stripe_charge_id,
                      "reason" => reason
                    }, charge_date: charge.created_at
                  ).and_return(perform_stripe_refund_result)
                  expect(InsertActivities).to receive(:for_refunds)
                end

                let!(:modern_refund_call) do
                  transaction
                  InsertRefunds.modern_refund(charge.attributes.with_indifferent_access, {
                    amount: amount_to_refund,
                    comment: comment,
                    reason: reason
                  }.with_indifferent_access)
                end

                it "has an accurate refund_payment" do
                  expect(refund_payment.gross_amount).to eq(-amount_to_refund)
                  expect(refund_payment.fee_total).to eq amount_of_fees_to_refund
                  expect(refund_payment.net_amount).to eq(-amount_to_refund + amount_of_fees_to_refund)
                  expect(refund_payment.kind).to eq "Refund"
                end

                it "has an accurate original_payment" do
                  original_payment.reload

                  expect(original_payment.refund_total).to eq ending_refund_total
                end

                it "has an accurate refund" do
                  expect(refund.amount).to eq amount_to_refund
                  expect(refund.comment).to eq comment
                  expect(refund.reason).to eq reason
                end

                it "has an accurate misc_refund_info" do
                  expect(misc_refund_info.is_modern).to eq true
                  if amount_of_fees_to_refund > 0
                    expect(misc_refund_info.stripe_application_fee_refund_id).to eq stripe_app_fee_refund.id
                  else
                    expect(misc_refund_info.stripe_application_fee_refund_id).to be_nil
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
