# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "stripe"

Stripe.api_key = Settings.payment_provider.stripe_private_key
Stripe.api_version = "2017-06-05"

Stripe.logger = Rails.logger
