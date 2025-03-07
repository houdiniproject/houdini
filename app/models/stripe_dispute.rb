# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class StripeDispute < ApplicationRecord

  TERMINAL_DISPUTE_STATUSES = ['won', 'lost']

  attr_accessible  :object, :stripe_dispute_id
  has_one :dispute, primary_key: :stripe_dispute_id, foreign_key: :stripe_dispute_id
  has_one :charge, primary_key: :stripe_charge_id, foreign_key: :stripe_charge_id
  after_save :fire_change_events

  def object=(input)
    serialize_on_update(input)
  end

  def balance_transactions_state
    StripeDispute.calc_balance_transaction_state(balance_transactions)
  end

  def funds_withdrawn_balance_transaction
    balance_transactions.any? ? balance_transactions.sort_by{|i| i['created']}[0] : nil
  end

  def funds_reinstated_balance_transaction
    balance_transactions.count == 2 ? balance_transactions.sort_by{|i| i['created']}[1] : nil
  end
  
  private
  def serialize_on_update(input)

    object_json = nil
    
    case input
    when Stripe::Dispute
      write_attribute(:object, input.to_hash)
      object_json = self.object
    when String
      write_attribute(:object, input)
      object_json = self.object
    end

    self.balance_transactions = object_json['balance_transactions']
    
    self.reason = object_json['reason']
    self.status = object_json['status']
    self.net_change = object_json['balance_transactions'].map{|i| i['net']}.sum
    self.amount = object_json['amount']
    self.stripe_dispute_id = object_json['id']
    self.stripe_charge_id = object_json['charge']
    self.evidence_due_date = (object_json['evidence_details'] && object_json['evidence_details']['due_by']) ? 
                        Time.at(object_json['evidence_details']['due_by']) :
                        nil
    self.started_at = Time.at(object_json['created'])

    self.object
  end
  
  def fire_change_events
    if saved_changes? && !dispute&.is_legacy
      if after_save_changed_attributes["object"].nil?
        dispute_created_event
      end

      if saved_change_to_attribute?(:balance_transactions)

        old_bt, _ = saved_changes[:balance_transactions]
        old_state = StripeDispute.calc_balance_transaction_state(old_bt)
        if old_state != balance_transactions_state

          if (old_state == :none)
            if( balance_transactions_state == :funds_withdrawn)
              dispute_funds_withdrawn_event
            else
              dispute_funds_withdrawn_event
              dispute_funds_reinstated_event
            end
          elsif (old_state == :funds_withdrawn)
            if (balance_transactions_state == :funds_reinstated)
              dispute_funds_reinstated_event
            else
              raise RuntimeError("Dispute #{dispute.id} previously had a balance_transaction_state of #{old_state} but is now #{balance_transactions_state}. " +
                "This shouldn't be possible.")
            end
          elsif (balance_transactions_state != :funds_reinstated)
            raise RuntimeError("Dispute #{dispute.id} previously had a balance_transaction_state of #{old_state} but is now #{balance_transactions_state}. " +
              "This shouldn't be possible.")
          end
        end
      end

      if saved_change_to_attribute?(:status)
        if TERMINAL_DISPUTE_STATUSES.include?(after_save_changed_attributes['status']) && !TERMINAL_DISPUTE_STATUSES.include?(status)
          # if previous status was won or lost and the new one isn't
          raise RuntimeError("Dispute #{dispute.id} was previously #{after_save_changed_attributes['status']} but is now #{status}. " +
              "This shouldn't be possible")
        elsif (!TERMINAL_DISPUTE_STATUSES.include?(after_save_changed_attributes['status']) && TERMINAL_DISPUTE_STATUSES.include?(status))
          # previous status was not won or lost but the new one is

          dispute_closed_event
        else
          if (after_save_changed_attributes["status"] != nil)
            # previous status was not won or lost but the new one still isn't but there were changes!
            dispute_updated_event
          end
        end
      elsif (!saved_change_to_attribute?(:balance_transactions) && after_save_changed_attributes["object"].nil?)
        dispute_updated_event
      end
    end
  end

  def dispute_created_event
    create_dispute!(charge:charge, status:status, reason: reason, gross_amount:amount, started_at: started_at)
    
    # notify folks of the event being opened
    dispute.activities.create('DisputeCreated', started_at)
    JobQueue.queue(JobTypes::DisputeCreatedJob, dispute)
  end

  def dispute_funds_withdrawn_event
    gross_amount = funds_withdrawn_balance_transaction["amount"]
    fee_total = -1 * funds_withdrawn_balance_transaction['fee']
    transaction = dispute.dispute_transactions.create(gross_amount:gross_amount, fee_total: fee_total , 
      payment: dispute.supporter.payments.create(nonprofit: dispute.nonprofit, 
        gross_amount:gross_amount, 
        fee_total: fee_total,
        net_amount: gross_amount + fee_total,
        kind: 'Dispute',
        date: Time.at(funds_withdrawn_balance_transaction["created"])
      ),
      stripe_transaction_id: funds_withdrawn_balance_transaction['id'],
      date: Time.at(funds_withdrawn_balance_transaction["created"])
    )

    # add dispute payment activity
    transaction.payment.activities.create

    transaction.dispute.original_payment.refund_total += gross_amount * -1
    transaction.dispute.original_payment.save!
    # notify folks of the withdrawal
    JobQueue.queue(JobTypes::DisputeFundsWithdrawnJob, dispute)
  end

  def dispute_funds_reinstated_event
    gross_amount = funds_reinstated_balance_transaction["amount"]
    fee_total = -1 * funds_reinstated_balance_transaction['fee']
    transaction = dispute.dispute_transactions.create(gross_amount:gross_amount, fee_total: fee_total, 
      payment: dispute.supporter.payments.create(nonprofit: dispute.nonprofit, 
        gross_amount:gross_amount, 
        fee_total: fee_total,
        net_amount: gross_amount + fee_total,
        kind: 'DisputeReversed',
        date: Time.at(funds_reinstated_balance_transaction["created"])
      ),
      stripe_transaction_id: funds_reinstated_balance_transaction['id'],
      date: Time.at(funds_reinstated_balance_transaction["created"])
    )

    transaction.dispute.original_payment.refund_total += gross_amount * -1
    transaction.dispute.original_payment.save!
    # add dispute payment activity
    transaction.payment.activities.create
    JobQueue.queue(JobTypes::DisputeFundsReinstatedJob, dispute)
  end

  def dispute_closed_event
    dispute.status = status
    dispute.save!
    if (dispute.status == 'won') 
      dispute.activities.create('DisputeWon', Time.now)
      JobQueue.queue(JobTypes::DisputeWonJob, dispute)
    elsif  dispute.status == 'lost'
      dispute.activities.create('DisputeLost', Time.now)
      JobQueue.queue(JobTypes::DisputeLostJob, dispute)
    else
      raise RuntimeError("Dispute #{dispute.id} was closed " +
        "but had status of #{dispute.status}")
    end
  end

  def dispute_updated_event
    dispute.activities.create('DisputeUpdated', Time.now)
    JobQueue.queue(JobTypes::DisputeUpdatedJob, dispute)
  end

  def self.calc_balance_transaction_state(balance_transactions)
    !balance_transactions || balance_transactions.count == 0 ? 
        :none :
           balance_transactions.count == 1 ?
             :funds_withdrawn :
             :funds_reinstated
  end

  private
  
  def after_save_changed_attributes
    saved_changes.transform_values(&:first)
  end
end
