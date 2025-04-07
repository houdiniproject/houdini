# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class OfflineTransactionRefund < ApplicationRecord
  include Model::SubtransactionPaymentable
  belongs_to :payment

  delegate :gross_amount, :net_amount, :fee_total, to: :payment

  delegate :currency, to: :nonprofit

  def gross_amount_as_money
    Amount.new(gross_amount || 0, currency)
  end

  def net_amount_as_money
    Amount.new(net_amount || 0, currency)
  end

  def fee_total_as_money
    Amount.new(fee_total || 0, currency)
  end

  def created
    payment.date
  end

  # rubocop:disable Metrics/BlockLength
  concerning :JBuilder do
    included do
      setup_houid :offtrxrfnd
    end

    # rubocop:disable Metrics/AbcSize
    def to_builder(*expand)
      init_builder(*expand) do |json|
        json.object "offline_transaction_refund"
        json.gross_amount do
          json.cents gross_amount
          json.currency currency
        end

        json.net_amount do
          json.cents net_amount
          json.currency currency
        end

        json.fee_total do
          json.cents fee_total
          json.currency currency
        end

        json.created payment.date.to_i
        json.type "payment"
        json.add_builder_expansion :nonprofit, :supporter, :subtransaction
        json.add_builder_expansion :trx, json_attribute: :transaction
      end
    end
    # rubocop:enable Metrics/AbcSize

    def to_id
      ::Jbuilder.new do |json|
        json.call(self, :id)
        json.object "offline_transaction_refund"
        json.type "payment"
      end
    end

    def publish_created
      Houdini.event_publisher.announce(
        :offline_transaction_refund_created,
        to_event("offline_transaction_refund.created",
          :nonprofit,
          :trx,
          :supporter,
          :subtransaction).attributes!
      )
      Houdini.event_publisher.announce(
        :payment_created,
        to_event("payment.created",
          :nonprofit,
          :trx,
          :supporter,
          :subtransaction).attributes!
      )
    end

    def publish_updated
      Houdini.event_publisher.announce(
        :offline_transaction_refund_updated,
        to_event("offline_transaction_refund.updated", :nonprofit, :trx, :supporter, :subtransaction).attributes!
      )
      Houdini.event_publisher.announce(
        :payment_updated,
        to_event("payment.updated", :nonprofit, :trx, :supporter, :subtransaction).attributes!
      )
    end

    def publish_deleted
      Houdini.event_publisher.announce(
        :offline_transaction_refund_deleted,
        to_event("offline_transaction_refund.deleted", :nonprofit, :trx, :supporter, :subtransaction).attributes!
      )
      Houdini.event_publisher.announce(
        :payment_deleted,
        to_event("payment.deleted", :nonprofit, :trx, :supporter, :subtransaction).attributes!
      )
    end
  end
  # rubocop:enable Metrics/BlockLength
end
