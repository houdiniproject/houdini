class StripeAccount < ActiveRecord::Base
  attr_accessible  :object, :stripe_account_id
  has_one :nonprofit, primary_key: :stripe_account_id
  has_one :nonprofit_verification_process_status, primary_key: :stripe_account_id

  def object=(input)
    serialize_on_update(input)
  end

  def verification_status
    if pending_verification.any?
      result = :pending
    elsif needs_immediate_validation_info
      result = :unverified
    elsif needs_more_validation_info
      result = :temporarily_verified
    else
      result = :verified
    end
    result
  end

  def deadline
    obj = object

    if obj['requirements'] && obj['requirements']['current_deadline'] && obj['requirements']['current_deadline'].to_i != 0
      return Time.at(obj['requirements']['current_deadline'].to_i)
    end
    nil
  end

  def needs_more_validation_info
    validation_arrays = [self.currently_due, self.past_due, self.eventually_due].map{|i| i || []}
    validation_arrays.any? do |i| 
      !i.none? && !i.all? do |j| 
        j.starts_with?('external_account')
      end
    end
  end

  def needs_immediate_validation_info
    validation_arrays = [self.currently_due, self.past_due].map{|i| i || []}
    deadline || validation_arrays.any? do |i| 
      !i.none? && !i.all? do |j| 
        j.starts_with?('external_account')
      end
    end
  end

  private 
  def serialize_on_update(input)

    object_json = nil
    
    case input
    when Stripe::Account
      write_attribute(:object, input.to_hash)
      object_json = self.object
      puts self.object
    when String
      write_attribute(:object, input)
      object_json = self.object
    end
    self.charges_enabled = !!object_json['charges_enabled']
    self.payouts_enabled = !!object_json['payouts_enabled']
    requirements = object_json['requirements'] || {}
    self.disabled_reason =  requirements['disabled_reason']
    self.currently_due = requirements['currently_due'] || []
    self.past_due =  requirements['past_due'] || []
    self.eventually_due =  requirements['eventually_due'] || []
    self.pending_verification = requirements['pending_verification'] || []

    unless self.stripe_account_id
      self.stripe_account_id = object_json['id']
    end

    self.object
  end
end
