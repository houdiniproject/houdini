# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

# rubocop:disable Metrics/BlockLength, Metrics/AbcSize
class OfflineTransactionCharge < ApplicationRecord
  include Model::SubtransactionPaymentable
  belongs_to :payment

  delegate :gross_amount, :net_amount, :fee_total, to: :payment

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

  delegate :currency, to: :nonprofit

  concerning :JBuilder do
    included do
      setup_houid :offtrxchrg
    end

    def to_builder(*expand)
      init_builder(*expand) do |json|
        json.object "offline_transaction_charge"
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

    def to_id
      ::Jbuilder.new do |json|
        json.call(self, :id)
        json.object "offline_transaction_charge"
        json.type "payment"
      end
    end

    def publish_created
      Houdini.event_publisher.announce(
        :offline_transaction_charge_created,
        to_event("offline_transaction_charge.created",
          :nonprofit,
          :trx,
          :supporter,
          :subtransaction).attributes!
      )
      Houdini.event_publisher.announce(
        :payment_created,
        to_event(
          "payment.created",
          :nonprofit,
          :trx,
          :supporter,
          :subtransaction
        ).attributes!
      )
    end
  end
end
# rubocop:enable all
