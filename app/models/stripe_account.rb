class StripeAccount < ActiveRecord::Base
  attr_accessible  :object
  attr_readonly :currently_due, :past_due, :eventually_due, :pending_verification
  has_one :nonprofit, primary_key: :stripe_account_id

  def object=(input)
    serialize_on_update(input)
  end

  def currently_due
    JSON::parse(read_attribute(:currently_due))
  end

  def past_due
    JSON::parse(read_attribute(:past_due))
  end

  def eventually_due
    JSON::parse(read_attribute(:eventually_due))
  end

  def pending_verification
    JSON::parse(read_attribute(:pending_verification))
  end

  def verification_status
    if eventually_due.any? || currently_due.any? || past_due.any?
      result = :unverified
    elsif (pending_verification.any?)
      result = :pending
    else
      result = :verified
    end
    result
  end

  private 
  def serialize_on_update(input)

    object_json = nil
    
    case input
    when Stripe::Account
      write_attribute(:object, input.to_s)
      object_json = JSON::parse(self.object)
      puts self.object
    when String
      write_attribute(:object, input)
      object_json = JSON::parse(input)
    end

    self.charges_enabled = !!object_json['charges_enabled']
    self.payouts_enabled = !!object_json['payouts_enabled']
    requirements = object_json['requirements'] || []
    self.disabled_reason =  requirements['disabled_reason']
    puts "to currently due"
    self.currently_due = JSON.generate(requirements['currently_due'] || [])
    self.past_due =  JSON.generate(requirements['past_due'] || [])
    self.eventually_due =  JSON.generate(requirements['eventually_due'] || [])
    self.pending_verification =  JSON.generate(requirements['pending_verification'] || [])

    unless self.stripe_account_id
      self.stripe_account_id = object_json['id']
    end

    self.object
  end
end
