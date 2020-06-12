# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class Houdini::PaymentProvider::StripeProvider
    include ActiveModel::AttributeAssignment

    attr_accessor :private_key, :public_key, :connect, :proprietary_v2_js
    def initialize(attributes={})
        assign_attributes(attributes) if attributes
        require 'stripe'
        Stripe.api_key = private_key
    end
end