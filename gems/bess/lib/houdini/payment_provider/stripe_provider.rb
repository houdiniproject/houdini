# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class Houdini::PaymentProvider::StripeProvider
  include ActiveModel::AttributeAssignment

  attr_accessor :private_key, :public_key, :connect, :proprietary_v2_js
  def initialize(attributes = {})
    # attributes will always be from OrderedOptions so we'll make this .to_h for now
    assign_attributes(attributes.to_h)
    require "stripe"
    Stripe.api_key = private_key
  end
end
