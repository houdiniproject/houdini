# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

# rubocop:disable Metrics/BlockLength, Metrics/AbcSize
class OfflineTransactionCharge < ApplicationRecord
  include Model::SubtransactionPaymentable
  has_one :legacy_payment, class_name: "Payment", through: :subtransaction_payment
  has_one :offsite_payment, through: :legacy_payment

  delegate :gross_amount, :net_amount, :fee_total, to: :legacy_payment
  delegate :currency, to: :nonprofit

  as_money :gross_amount, :net_amount, :fee_total

  def created
    legacy_payment.date
  end

  def publish_created
    object_events.create(event_type: "offline_transaction_charge.created")
  end

  def publish_updated
    object_events.create(event_type: "offline_transaction_charge.updated")
  end

  def publish_deleted
    object_events.create(event_type: "offline_transaction_charge.deleted")
  end

  concerning :JBuilder do
    included do
      setup_houid :offtrxchrg, :houid
    end
  end
end
# rubocop:enable all
