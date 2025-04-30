# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Model::TrxAssignable
  extend ActiveSupport::Concern

  included do
    include Model::Houidable

    has_one :transaction_assignment, as: :assignable
    has_one :trx, through: :transaction_assignment, class_name: "Transaction", foreign_key: "transaction_id"
    has_one :supporter, through: :transaction_assignment
    has_one :nonprofit, through: :transaction_assignment

    delegate :currency, to: :nonprofit

    has_many :object_events, as: :event_entity
  end
end
