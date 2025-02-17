# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe OfflineTransactionRefund do
  let!(:nonprofit) { create(:nm_justice) }
  let!(:supporter) { force_create(:supporter, nonprofit: nonprofit) }

  let(:offline_transaction_refund) do
    build(
      :offline_transaction_refund,
      payment:
         force_create(
           :payment,
           gross_amount: 500,
           net_amount: 400,
           fee_total: 100,
           date: Time.zone.now,
           nonprofit: nonprofit,
           supporter: supporter
         )
    )
  end
  let(:offline_transaction_charge) do
    build(
      :offline_transaction_charge,
      payment:
         force_create(
           :payment,
           gross_amount: 400,
           net_amount: 300,
           fee_total: 100,
           date: Time.zone.now,
           nonprofit: nonprofit,
           supporter: supporter
         )
    )
  end

  let(:offline_transaction) { build(:offline_transaction) }
  let(:transaction) do
    trx = supporter.transactions.build(amount: 500)
    trx.build_subtransaction(
      subtransactable: OfflineTransaction.new(amount: 500),
      payments: [
        build(:subtransaction_payment, paymentable: offline_transaction_refund),
        build(:subtransaction_payment, paymentable: offline_transaction_charge)
      ]
    )
    trx.save!
    trx
  end

  let(:event_publisher) { double }

  let(:expected_event) do
    {
      "data" => {
        "object" => {
          "created" => kind_of(Numeric),
          "fee_total" => {"cents" => 100, "currency" => nonprofit.currency},
          "gross_amount" => {"cents" => 500, "currency" => nonprofit.currency},
          "id" => match_houid("offtrxrfnd"),
          "net_amount" => {"cents" => 400, "currency" => nonprofit.currency},
          "nonprofit" => {
            "id" => nonprofit.id,
            "name" => nonprofit.name,
            "object" => "nonprofit"
          },
          "object" => "offline_transaction_refund",
          "subtransaction" => {
            "created" => kind_of(Numeric),
            "id" => match_houid("offlinetrx"),
            "initial_amount" => {"cents" => 500, "currency" => nonprofit.currency},
            "net_amount" => {"cents" => 700, "currency" => nonprofit.currency},
            "nonprofit" => nonprofit.id,
            "object" => "offline_transaction",
            "payments" => [
              {
                "id" => match_houid("offtrxrfnd"),
                "object" => "offline_transaction_refund",
                "type" => "payment"
              }, {
                "id" => match_houid("offtrxchrg"),
                "object" => "offline_transaction_charge",
                "type" => "payment"
              }
            ],
            "supporter" => supporter.id,
            "transaction" => match_houid("trx"),
            "type" => "subtransaction"
          },
          "supporter" => {
            "anonymous" => false,
            "deleted" => false,
            "id" => supporter.id,
            "merged_into" => nil,
            "name" => supporter.name,
            "nonprofit" => kind_of(Numeric),
            "object" => "supporter",
            "organization" => nil,
            "phone" => nil,
            "supporter_addresses" => [kind_of(Numeric)]
          },
          "transaction" => {
            "amount" => {"cents" => 500, "currency" => nonprofit.currency},
            "created" => kind_of(Numeric),
            "id" => match_houid("trx"),
            "nonprofit" => kind_of(Numeric),
            "object" => "transaction",
            "subtransaction" => {
              "id" => match_houid("offlinetrx"),
              "object" => "offline_transaction",
              "type" => "subtransaction"
            },
            "payments" => [
              {
                "id" => match_houid("offtrxrfnd"),
                "object" => "offline_transaction_refund",
                "type" => "payment"
              }, {
                "id" => match_houid("offtrxchrg"),
                "object" => "offline_transaction_charge",
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

  before do
    allow(Houdini)
      .to receive(:event_publisher)
      .and_return(event_publisher)
    transaction
  end

  describe "offline transaction refund" do
    subject { offline_transaction_refund }

    it do
      is_expected
        .to have_attributes(
          nonprofit: an_instance_of(Nonprofit),
          id: match_houid("offtrxrfnd")
        )
    end

    it { is_expected.to be_persisted }
  end

  describe ".to_builder" do
    subject { JSON.parse(offline_transaction_refund.to_builder.target!) }

    it do
      is_expected
        .to match_json(
          {
            object: "offline_transaction_refund",
            nonprofit: kind_of(Numeric),
            supporter: kind_of(Numeric),
            id: match_houid("offtrxrfnd"),
            type: "payment",
            fee_total: {cents: 100, currency: nonprofit.currency},
            net_amount: {cents: 400, currency: nonprofit.currency},
            gross_amount: {cents: 500, currency: nonprofit.currency},
            created: kind_of(Numeric),
            subtransaction: {
              id: match_houid("offlinetrx"),
              object: "offline_transaction",
              type: "subtransaction"
            },
            transaction: match_houid("trx")
          }
        )
    end
  end

  describe ".publish_created" do
    before do
      expected_event["type"] = "offline_transaction_refund.created"

      allow(event_publisher)
        .to receive(:announce)
        .with(:payment_created, anything)
      allow(event_publisher)
        .to receive(:announce)
        .with(
          :offline_transaction_refund_created,
          expected_event
        )
    end

    it "announces offline_transaction_refund.created event" do
      offline_transaction_refund.publish_created

      expect(event_publisher)
        .to have_received(:announce)
        .with(
          :offline_transaction_refund_created,
          expected_event
        )
    end
  end

  describe ".publish_updated" do
    before do
      expected_event["type"] = "offline_transaction_refund.updated"

      allow(event_publisher)
        .to receive(:announce)
        .with(:payment_updated, anything)
      allow(event_publisher)
        .to receive(:announce)
        .with(
          :offline_transaction_refund_updated,
          expected_event
        )
    end

    it "announces offline_transaction_refund.updated event" do
      offline_transaction_refund.publish_updated

      expect(event_publisher)
        .to have_received(:announce)
        .with(
          :offline_transaction_refund_updated,
          expected_event
        )
    end
  end

  describe ".publish_deleted" do
    before do
      expected_event["type"] = "offline_transaction_refund.deleted"

      allow(event_publisher)
        .to receive(:announce)
        .with(:payment_deleted, anything)
      allow(event_publisher)
        .to receive(:announce)
        .with(
          :offline_transaction_refund_deleted,
          expected_event
        )
    end

    it "announces offline_transaction_refund.deleted event" do
      offline_transaction_refund.publish_deleted

      expect(event_publisher)
        .to have_received(:announce)
        .with(
          :offline_transaction_refund_deleted,
          expected_event
        )
    end
  end
end
