# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class StripeTransactionDisputeReversal < ApplicationRecord
  include Model::SubtransactionPaymentable
  setup_houid :stripedisprvrs, :houid

  has_one :legacy_payment, class_name: "Payment", through: :subtransaction_payment

  delegate :gross_amount, :net_amount, :fee_total, to: :legacy_payment

  delegate :currency, to: :nonprofit

  as_money :gross_amount, :net_amount, :fee_total

  def created
    legacy_payment.date
  end

  def publish_created
    object_events.create(event_type: "stripe_transaction_dispute_reversal.created")
  end

  def publish_updated
    object_events.create(event_type: "stripe_transaction_dispute_reversal.updated")
  end

  def publish_deleted
    object_events.create(event_type: "stripe_transaction_dispute_reversal.deleted")
  end
end
