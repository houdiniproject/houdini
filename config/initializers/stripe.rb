# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'stripe'

Stripe.api_key = Settings.payment_provider.stripe_private_key
