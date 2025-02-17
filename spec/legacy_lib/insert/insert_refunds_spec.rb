# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe InsertRefunds do
  let!(:nonprofit) { create(:nm_justice) }
  let!(:supporter) { create(:supporter, nonprofit: nonprofit) }

  let!(:payment) do
    force_create(
      :payment,
      gross_amount: 500,
      net_amount: CalculateFees.for_single_amount(500) + 500,
      fee_total: CalculateFees.for_single_amount(500),
      date: Time.zone.now,
      nonprofit: nonprofit,
      supporter: supporter,
      refund_total: 0
    )
  end

  let!(:charge) do
    create(
      :charge,
      payment: payment,
      stripe_charge_id: "ch_s0m3th1ng",
      nonprofit: nonprofit,
      supporter: supporter,
      amount: 500
    )
  end

  before do
    trx = supporter.transactions.build(amount: 500)
    trx.build_subtransaction(
      subtransactable: StripeTransaction.new(amount: 500),
      payments: [
        build(:subtransaction_payment, paymentable: create(:stripe_charge, payment: payment))
      ]
    )
    trx.save!
    trx
  end

  describe ".with_stripe" do
    context "when invalid" do
      it "raises an error with an invalid charge" do
        charge.update(stripe_charge_id: "xxx")
        expect { described_class.with_stripe(charge, amount: 1) }.to raise_error(ParamValidation::ValidationError)
      end

      it "sets a failure message an error with an invalid amount" do
        charge.update(amount: 0)
        expect { described_class.with_stripe(charge, amount: 0) }.to raise_error(ParamValidation::ValidationError)
      end

      it "returns err if refund amount is greater than payment gross minus payment refund total" do
        expect { described_class.with_stripe(charge, "amount" => 600) }.to raise_error(RuntimeError)
      end
    end

    context "when valid" do
      let(:result) { described_class.with_stripe(charge, "amount" => 100) }

      let(:retrieved_stripe_charge) { double }
      let(:stripe_charge_refunds) { double }
      let(:created_stripe_charge_refund) { double }

      before do
        allow(Stripe::Charge)
          .to receive(:retrieve)
          .with("ch_s0m3th1ng")
          .and_return(retrieved_stripe_charge)
        allow(retrieved_stripe_charge)
          .to receive(:refunds)
          .and_return(stripe_charge_refunds)
        allow(stripe_charge_refunds)
          .to receive(:create)
          .with({"amount" => 100, "refund_application_fee" => true, "reverse_transfer" => true})
          .and_return(created_stripe_charge_refund)
        allow(created_stripe_charge_refund)
          .to receive(:id)
          .and_return("re_f@k3")
      end

      it "sets the stripe refund id" do
        expect(result["refund"]["stripe_refund_id"]).to match(/^re_/)
      end

      it "creates a negative payment for the refund with the gross amount" do
        expect(result["payment"]["gross_amount"]).to eq(-100)
      end

      it "creates a negative payment for the refund with the net amount" do
        expect(result["payment"]["net_amount"]).to eq(-109)
      end

      it "updates the payment_id on the refund" do
        expect(result["refund"]["payment_id"]).to eq(result["payment"]["id"])
      end

      it "increments the payment refund total by the gross amount" do
        result
        expect(payment.reload["refund_total"]).to eq(100)
      end

      it "sets the payment supporter id" do
        expect(result["payment"]["supporter_id"]).to eq(supporter["id"])
      end

      describe "event publishing" do
        let(:event_publisher) { double }
        let(:expected_event) do
          {
            "data" => {
              "object" => {
                "created" => kind_of(Numeric),
                "fee_total" => {
                  "cents" => -9, "currency" => nonprofit.currency
                },
                "gross_amount" => {
                  "cents" => -100, "currency" => nonprofit.currency
                },
                "id" => match_houid("striperef"),
                "stripe_id" => kind_of(String),
                "net_amount" => {
                  "cents" => -109, "currency" => nonprofit.currency
                },
                "nonprofit" => {
                  "id" => nonprofit.id,
                  "name" => nonprofit.name,
                  "object" => "nonprofit"
                },
                "object" => "stripe_transaction_refund",
                "subtransaction" => {
                  "created" => kind_of(Numeric),
                  "id" => match_houid("stripetrx"),
                  "initial_amount" => {
                    "cents" => 500, "currency" => nonprofit.currency
                  },
                  "net_amount" => {
                    "cents" => 432, "currency" => nonprofit.currency
                  },
                  "nonprofit" => nonprofit.id,
                  "object" => "stripe_transaction",
                  "payments" => [
                    {
                      "id" => match_houid("stripechrg"),
                      "object" => "stripe_transaction_charge",
                      "type" => "payment"
                    },
                    {
                      "id" => match_houid("striperef"),
                      "object" => "stripe_transaction_refund",
                      "type" => "payment"
                    }
                  ],
                  "supporter" => supporter.id,
                  "transaction" => match_houid("trx"),
                  "type" => "subtransaction"
                },
                "supporter" => {
                  "anonymous" => supporter.anonymous,
                  "deleted" => supporter.deleted,
                  "id" => supporter.id,
                  "merged_into" => supporter.merged_into,
                  "name" => supporter.name,
                  "nonprofit" => nonprofit.id,
                  "object" => "supporter",
                  "organization" => supporter.organization,
                  "phone" => supporter.phone,
                  "supporter_addresses" => [kind_of(Numeric)]
                },
                "transaction" => {
                  "amount" => {
                    "cents" => 400, "currency" => nonprofit.currency
                  },
                  "created" => kind_of(Numeric),
                  "id" => match_houid("trx"),
                  "nonprofit" => nonprofit.id,
                  "object" => "transaction",
                  "subtransaction" => {
                    "id" => match_houid("stripetrx"),
                    "object" => "stripe_transaction",
                    "type" => "subtransaction"
                  },
                  "payments" => [
                    {
                      "id" => match_houid("stripechrg"),
                      "object" => "stripe_transaction_charge",
                      "type" => "payment"
                    }, {
                      "id" => match_houid("striperef"),
                      "object" => "stripe_transaction_refund",
                      "type" => "payment"
                    }
                  ],
                  "supporter" => supporter.id,
                  "transaction_assignments" => []
                },
                "type" => "payment"
              }
            },
            "id" => match_houid("objevt"),
            "object" => "object_event",
            "type" => "event_type"
          }
        end

        let(:expected_transaction_event) do
          {
            "data" => {
              "object" => {
                "amount" => {
                  "cents" => 400,
                  "currency" => nonprofit.currency
                },
                "created" => kind_of(Numeric),
                "id" => match_houid("trx"),
                "nonprofit" => {
                  "id" => nonprofit.id,
                  "name" => nonprofit.name,
                  "object" => "nonprofit"
                },
                "object" => "transaction",
                "subtransaction" => {
                  "created" => kind_of(Numeric),
                  "id" => match_houid("stripetrx"),
                  "initial_amount" => {
                    "cents" => 500,
                    "currency" => nonprofit.currency
                  },
                  "net_amount" => {
                    "cents" => 432,
                    "currency" => nonprofit.currency
                  },
                  "nonprofit" => nonprofit.id,
                  "object" => "stripe_transaction",
                  "payments" => [
                    {
                      "id" => match_houid("stripechrg"),
                      "object" => "stripe_transaction_charge",
                      "type" => "payment"
                    }, {
                      "id" => match_houid("striperef"),
                      "object" => "stripe_transaction_refund",
                      "type" => "payment"
                    }
                  ],
                  "supporter" => supporter.id,
                  "transaction" => match_houid("trx"),
                  "type" => "subtransaction"
                },
                "payments" => [
                  {
                    "created" => kind_of(Numeric),
                    "fee_total" => {
                      "cents" => 41,
                      "currency" => nonprofit.currency
                    },
                    "gross_amount" => {
                      "cents" => 500,
                      "currency" => nonprofit.currency
                    },
                    "id" => match_houid("stripechrg"),
                    "net_amount" => {
                      "cents" => 541,
                      "currency" => nonprofit.currency
                    },
                    "nonprofit" => nonprofit.id,
                    "object" => "stripe_transaction_charge",
                    "stripe_id" => "ch_s0m3th1ng",
                    "subtransaction" => {
                      "id" => match_houid("stripetrx"),
                      "object" => "stripe_transaction",
                      "type" => "subtransaction"
                    },
                    "supporter" => supporter.id,
                    "transaction" => match_houid("trx"),
                    "type" => "payment"
                  }, {
                    "created" => kind_of(Numeric),
                    "fee_total" => {
                      "cents" => -9,
                      "currency" => nonprofit.currency
                    },
                    "gross_amount" => {
                      "cents" => -100,
                      "currency" => nonprofit.currency
                    },
                    "id" => match_houid("striperef"),
                    "net_amount" => {
                      "cents" => -109,
                      "currency" => nonprofit.currency
                    },
                    "nonprofit" => nonprofit.id,
                    "object" => "stripe_transaction_refund",
                    "stripe_id" => "re_f@k3",
                    "subtransaction" => {
                      "id" => match_houid("stripetrx"),
                      "object" => "stripe_transaction",
                      "type" => "subtransaction"
                    },
                    "supporter" => supporter.id,
                    "transaction" => match_houid("trx"),
                    "type" => "payment"
                  }
                ],
                "supporter" => {
                  "anonymous" => false,
                  "deleted" => false,
                  "id" => supporter.id,
                  "merged_into" => nil,
                  "name" => supporter.name,
                  "nonprofit" => nonprofit.id,
                  "object" => "supporter",
                  "organization" => nil,
                  "phone" => nil,
                  "supporter_addresses" => [kind_of(Numeric)]
                },
                "transaction_assignments" => []
              }
            },
            "id" => match_houid("objevt"),
            "object" => "object_event",
            "type" => "transaction.updated"
          }
        end

        before do
          allow(Houdini)
            .to receive(:event_publisher)
            .and_return(event_publisher)

          allow(event_publisher)
            .to receive(:announce)
            .with(:payment_created, anything)

          allow(event_publisher)
            .to receive(:announce)
            .with(:stripe_transaction_refund_created, anything)

          allow(event_publisher)
            .to receive(:announce)
            .with(:transaction_refunded, anything)

          allow(event_publisher)
            .to receive(:announce)
            .with(:transaction_updated, anything)

          allow(event_publisher)
            .to receive(:announce)
            .with(:create_refund, anything)

          result
        end

        it "publishes that a transaction was updated" do
          expected_transaction_event["type"] = "transaction.updated"
          expect(event_publisher)
            .to have_received(:announce)
            .with(:transaction_updated, expected_transaction_event)
        end

        it "publishes that a transaction was refunded" do
          expected_transaction_event["type"] = "transaction.refunded"
          expect(event_publisher)
            .to have_received(:announce)
            .with(:transaction_refunded, expected_transaction_event)
        end

        it "publishes that a stripe_transaction_refund was created" do
          expected_event["type"] = "stripe_transaction_refund.created"
          expect(event_publisher)
            .to have_received(:announce)
            .with(:stripe_transaction_refund_created, expected_event)
        end

        it "publishes that a payment was created" do
          expected_event["type"] = "payment.created"
          expect(event_publisher)
            .to have_received(:announce)
            .with(:payment_created, expected_event)
        end

        it "publishes that a refund was created" do
          expect(event_publisher)
            .to have_received(:announce)
            .with(:create_refund, kind_of(Refund))
        end
      end
    end
  end
end
