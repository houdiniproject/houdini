# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Dispute < ApplicationRecord
  Reasons = [:unrecognized, :duplicate, :fraudulent, :subscription_canceled, :product_unacceptable, :product_not_received, :unrecognized, :credit_not_processed, :goods_services_returned_or_refused, :goods_services_cancelled, :incorrect_account_details, :insufficient_funds, :bank_cannot_process, :debit_not_authorized, :general]

  Statuses = [:needs_response, :under_review, :won, :lost]

  attr_accessible \
    :gross_amount, # int
    :charge_id, :charge,
    :status,
    :reason,
    :started_at

  attr_accessible \
    :withdrawal_transaction,
    :reinstatement_transaction

  belongs_to :charge
  has_one :stripe_dispute, foreign_key: :stripe_dispute_id, primary_key: :stripe_dispute_id
  has_many :dispute_transactions, -> { order("date ASC") }

  has_one :supporter, through: :charge
  has_one :nonprofit, through: :charge
  has_one :original_payment, through: :charge, source: :payment

  has_many :activities, as: :attachment do
    def create(event_type, event_time, attributes = nil, options = {}, &block)
      attributes = proxy_association.owner.build_activity_attributes(event_type, event_time).merge(attributes || {})
      proxy_association.create(attributes, options, &block)
    end

    def build(event_type, event_time, attributes = nil, options = {}, &block)
      attributes = proxy_association.owner.build_activity_attributes(event_type, event_time).merge(attributes || {})
      proxy_association.build(attributes, options, &block)
    end
  end

  def withdrawal_transaction
    dispute_transactions&.first
  end

  def reinstatement_transaction
    ((dispute_transactions&.count == 2) && dispute_transactions[1]) || nil
  end

  def get_original_payment
    charge&.payment
  end

  def build_activity_json(event_type)
    dispute = self
    original_payment = dispute.original_payment
    case event_type
    when "DisputeCreated", "DisputeUpdated", "DisputeLost", "DisputeWon"
      {
        gross_amount: dispute.gross_amount,
        reason: dispute.reason,
        status: dispute.status,
        original_id: original_payment.id,
        original_kind: original_payment.kind,
        original_gross_amount: original_payment.gross_amount,
        original_date: original_payment.date,
        started_at: dispute.started_at
      }
    else
      raise "#{event_type} is not a valid Dispute event type"
    end
  end

  def build_activity_attributes(event_type, event_time)
    dispute = self
    case event_type
    when "DisputeCreated", "DisputeUpdated", "DisputeLost", "DisputeWon"
      {
        kind: event_type,
        date: event_time,
        nonprofit: dispute.nonprofit,
        supporter: dispute.supporter,
        json_data: build_activity_json(event_type)
      }
    else
      raise "#{event_type} is not a valid Dispute event type"
    end
  end
end
