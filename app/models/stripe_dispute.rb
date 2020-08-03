# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class StripeDispute < ActiveRecord::Base
  attr_accessible  :object, :stripe_dispute_id
  has_one :dispute, primary_key: :stripe_dispute_id
  has_one :charge, primary_key: :charges

  def object=(input)
    serialize_on_update(input)
  end

  def balance_transactions
    JSON::parse(read_attribute(:balance_transactions))
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
end
