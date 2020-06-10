# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::PaymentProvider::StripeProvider
    include ActiveModel::AttributeAssignment

    attr_accessor :private_key, :public_key, :connect, :proprietary_v2_js
    def initialize(attributes={})
        assign_attributes(attributes) if attributes
        require 'stripe'
        Stripe.api_key = private_key
    end
end