# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class StripeTransactionCharge < ApplicationRecord
  include Model::SubtransactionPaymentable
  setup_houid :stripechrg, :houid

  has_one :legacy_payment, class_name: "Payment", through: :subtransaction_payment

  delegate :gross_amount, :net_amount, :fee_total, to: :legacy_payment

  as_money :gross_amount, :net_amount, :fee_total

  def created
    legacy_payment.date
  end

  def stripe_id
    legacy_payment.charge.stripe_charge_id
  end

  def publish_created
    object_events.create(event_type: "stripe_transaction_charge.created")
  end

  def publish_updated
    object_events.create(event_type: "stripe_transaction_charge.updated")
  end

  def publish_deleted
    object_events.create(event_type: "stripe_transaction_charge.deleted")
  end
end
