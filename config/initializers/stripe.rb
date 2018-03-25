require 'stripe'

Stripe.api_key = Settings.payment_provider.stripe_private_key;
