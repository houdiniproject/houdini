# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class StripeDispute < ActiveRecord::Base

  TERMINAL_DISPUTE_STATUSES = ['won', 'lost']

  attr_accessible  :object, :stripe_dispute_id
  has_one :dispute, primary_key: :stripe_dispute_id, foreign_key: :stripe_dispute_id
  has_one :charge, primary_key: :stripe_charge_id, foreign_key: :stripe_charge_id
  after_save :fire_change_events

  def object=(input)
    serialize_on_update(input)
  end

  def balance_transactions
    JSON::parse(read_attribute(:balance_transactions))
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
      write_attribute(:object, input.to_s)
      object_json = JSON::parse(self.object)
      puts self.object
    when String
      write_attribute(:object, input)
      object_json = JSON::parse(input)
    end

    self.balance_transactions = JSON.generate(object_json['balance_transactions'])
    
    self.reason = object_json['reason']
    self.status = object_json['status']
    self.net_change = object_json['balance_transactions'].map{|i| i['net']}.sum
    self.amount = object_json['amount']
    self.stripe_dispute_id = object_json['id']
    self.stripe_charge_id = object_json['charge']

    self.object
  end
  
  def fire_change_events
    if changed_attributes["object"].nil?
      dispute_opened_event
    end
    if balance_transactions_changed?

      old_bt, _ = balance_transactions_change
      old_state = StripeDispute.calc_balance_transaction_state(old_bt && JSON.parse(old_bt))
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
            #error!
          end
        elsif (balance_transactions_state != :funds_reinstated)
          #error!
        end
      end
    end

    if status_changed?
      if TERMINAL_DISPUTE_STATUSES.include?(changed_attributes['status']) && !TERMINAL_DISPUTE_STATUSES.include?(status)
        # if previous status was won or lost and the new one isn't
        #error
      elsif (!TERMINAL_DISPUTE_STATUSES.include?(changed_attributes['status']) && TERMINAL_DISPUTE_STATUSES.include?(status))
        # previous status was not won or lost but the new one is

        dispute_closed_event
      end
    end
  end

  def dispute_opened_event
    create_dispute!(charge:charge, status:status, reason: reason, gross_amount:amount)
    # notify folks of the event being opened
  end

  def dispute_funds_withdrawn_event
    gross_amount = funds_withdrawn_balance_transaction["amount"]
    fee_total = -1 * funds_withdrawn_balance_transaction['fee']
    dispute.dispute_transactions.create(gross_amount:gross_amount, fee_total: fee_total , 
      payment: dispute.supporter.payments.create(nonprofit: dispute.nonprofit, 
        gross_amount:gross_amount, 
        fee_total: fee_total,
        kind: 'Dispute',
        date: Time.at(funds_withdrawn_balance_transaction["created"])
      ),
      stripe_transaction_id: funds_withdrawn_balance_transaction['id'],
      date: Time.at(funds_withdrawn_balance_transaction["created"])
    )

    # add dispute payment activity
    # notify folks of the withdrawal
  end

  def dispute_funds_reinstated_event
    gross_amount = funds_reinstated_balance_transaction["amount"]
    fee_total = -1 * funds_reinstated_balance_transaction['fee']
    dispute.dispute_transactions.create(gross_amount:gross_amount, fee_total: fee_total, 
      payment: dispute.supporter.payments.create(nonprofit: dispute.nonprofit, 
        gross_amount:gross_amount, 
        fee_total: fee_total,
        kind: 'DisputeReversed',
        date: Time.at(funds_reinstated_balance_transaction["created"])
      ),
      stripe_transaction_id: funds_reinstated_balance_transaction['id'],
      date: Time.at(funds_reinstated_balance_transaction["created"])
    )

    # add dispute payment activity
    # notify folks of the reinstatement
  end

  def dispute_closed_event
    dispute.status = status
    dispute.save!
  end

  def self.calc_balance_transaction_state(balance_transactions)
    !balance_transactions || balance_transactions.count == 0 ? 
        :none :
           balance_transactions.count == 1 ?
             :funds_withdrawn :
             :funds_reinstated
  end
  
end
