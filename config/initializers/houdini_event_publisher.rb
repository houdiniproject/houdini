# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

Wisper.clear if Rails.env.development?

Rails.application.config.houdini.listeners.push(
  NonprofitMailerListener,
  CreditCardPaymentListener,
  SepaPaymentListener,
  TicketMailingListener,
  ObjectEventListener
)
