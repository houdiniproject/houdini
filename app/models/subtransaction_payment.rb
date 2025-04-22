# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class SubtransactionPayment < ApplicationRecord
  include Model::Houidable
  include Model::CreatedTimeable

  setup_houid :subtrxentity

  belongs_to :subtransaction
  has_one :trx, class_name: "Transaction", foreign_key: "transaction_id", through: :subtransaction
  has_one :supporter, through: :subtransaction
  has_one :nonprofit, through: :subtransaction

  delegated_type :paymentable, types: %w[
    OfflineTransactionCharge
    OfflineTransactionDispute
    OfflineTransactionRefund
    StripeCharge
    StripeRefund
  ]

  delegate :gross_amount, :fee_total, :net_amount, to: :paymentable

  scope :with_entities, -> { includes(:paymentable) }

  delegate :to_builder,
    :to_event,
    :to_id,
    :publish_created,
    :publish_updated,
    :publish_deleted, to: :paymentable
end
