# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class StripeCharge < ApplicationRecord
  attr_accessible :object, :stripe_charge_id
  has_one :charge, primary_key: :stripe_charge_id, foreign_key: :stripe_charge_id

  def object=(input)
    serialize_on_update(input)
  end

  def stripe_object
    Stripe::Util.convert_to_stripe_object(object)
  end

  private

  def serialize_on_update(input)
    object_json = nil

    case input
    when Stripe::Charge
      write_attribute(:object, input.to_hash)
      object_json = object
    when String
      write_attribute(:object, input)
      object_json = object
    end

    self.stripe_charge_id = object_json["id"]

    object
  end
end
