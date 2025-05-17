# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class Transaction < ApplicationRecord
  include Model::CreatedTimeable
  include Model::Houidable

  setup_houid :trx, :houid

  belongs_to :supporter, optional: false
  has_one :nonprofit, through: :supporter

  has_many :transaction_assignments, -> { extending ModelExtensions::TransactionAssignment::RefundExtension }, inverse_of: "trx"
  has_many :donations, through: :transaction_assignments, source: :assignable, source_type: "ModernDonation", inverse_of: "trx"
  has_many :ticket_purchases, through: :transaction_assignments, source: :assignable, source_type: "TicketPurchase", inverse_of: "trx"

  has_one :subtransaction, inverse_of: :trx
  has_many :payments, -> { extending ModelExtensions::PaymentsExtension }, through: :subtransaction, source: :subtransaction_payments, class_name: "SubtransactionPayment"

  has_many :object_events, as: :event_entity

  delegate :currency, to: :nonprofit

  as_money :amount

  # get payments in reverse chronological order
  def ordered_payments
    payments.ordered
  end

  # def designation
  # 	donation&.designation
  # end

  # def dedication
  # 	donation&.dedication
  # end

  concerning :Refunds do
    # Handle a completed refund from a legacy Refund object
    def process_refund(refund)
      new_refund = save_refund(refund)
      publish_after_refund(new_refund)
    end

    private

    # @param refund Refund a refund object
    # @returns StripeTransactionPayment (with a StripeTransactionRefund) represents the new refund
    def save_refund(refund)
      # add the refund to the subtransaction as a StripeTransactionRefund
      new_refund = subtransaction.process_refund(refund)
      # update the value of the transaction itself from the subtransaction
      self.amount = subtransaction.subtransactable.amount
      # refund means we need to adjust the values of the transaction_assignments
      transaction_assignments.process_refund(refund)
      # save everything
      save!

      new_refund
    end

    # @param refund StripeTransactionPayment (with a StripeTransactionRefund) represents the new refund
    def publish_after_refund(new_refund)
      publish_updated

      subtransaction.publish_updated
      # we want to publish that every payment has other than the new refund been updated
      payments.ordered.select { |i| i != new_refund }.each(&:publish_updated)
      # publish that the new_refund has been created
      new_refund.publish_created

      # publish that the transaction_assignments have been updated
      transaction_assignments.first.publish_updated
    end
  end

  def publish_created
    object_events.create(event_type: "transaction.created")
  end

  def publish_updated
    object_events.create(event_type: "transaction.updated")
  end

  def publish_deleted
    object_events.create(event_type: "transaction.deleted")
  end

  private

  def to_param
    persisted? && houid
  end
end

ActiveSupport.run_load_hooks(:houdini_transaction, Transaction)
