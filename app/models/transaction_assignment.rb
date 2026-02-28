# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class TransactionAssignment < ApplicationRecord
  include Model::Houidable
  setup_houid :trxassign

  delegated_type :assignable, types: ["ModernDonation", "CampaignGiftPurchase", "TicketPurchase"]

  delegate :to_id,
    :to_builder,
    :publish_created,
    :publish_updated,
    :publish_deleted, to: :assignable

  belongs_to :trx, class_name: "Transaction", foreign_key: "transaction_id"
  has_one :supporter, through: :trx
  has_one :nonprofit, through: :trx
end
