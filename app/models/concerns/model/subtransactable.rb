# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Model::Subtransactable
  extend ActiveSupport::Concern

  included do
    include Model::Houidable

    has_one :subtransaction, as: :subtransactable, dependent: :nullify
    has_one :trx, through: :subtransaction, class_name: "Transaction"
    has_one :supporter, through: :trx
    has_one :nonprofit, through: :trx

    has_many :subtransaction_payments, -> { extending ModelExtensions::PaymentsExtension }, through: :subtransaction

    delegate :currency, to: :nonprofit

    # Handle a completed refund from a legacy Refund object
    # Implement this in your specific subtransaction class if you want to use it.
    def process_refund(refund)
      raise NotImplementedError,
        "You need to implement 'process_refund' in your specific subtransaction class"
    end
  end
end
