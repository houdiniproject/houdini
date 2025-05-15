# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class TransactionAssignment < ApplicationRecord
  delegated_type :assignable, types: ["ModernDonation"]

  belongs_to :trx, class_name: "Transaction", foreign_key: "transaction_id", optional: false, inverse_of: :transaction_assignments
  has_one :supporter, through: :trx
  has_one :nonprofit, through: :trx

  validates :assignable, presence: true

  delegate :to_houid, :publish_updated, to: :assignable
end
