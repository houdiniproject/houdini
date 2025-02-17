# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class Subtransaction < ApplicationRecord
  include Model::CreatedTimeable

  concerning :JBuilder do
    include Model::Houidable
    included do
      setup_houid :subtrx
    end
  end

  belongs_to :trx, class_name: "Transaction", foreign_key: "transaction_id", inverse_of: :subtransaction
  has_one :supporter, through: :trx
  has_one :nonprofit, through: :trx

  has_many :payments, class_name: "SubtransactionPayment" # rubocop:disable Rails/HasManyOrHasOneDependent

  delegated_type :subtransactable, types: %w[OfflineTransaction StripeTransaction]

  scope :with_subtransactables, -> { includes(:subtransactable) }

  delegate :to_builder, :to_event, :to_id, :publish_created, :publish_updated, :publish_deleted, to: :subtransactable
end
