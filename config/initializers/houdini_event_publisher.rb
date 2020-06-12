# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

Wisper.clear if Rails.env.development?

Rails.application.config.houdini.listeners << [NonprofitMailerListener, 
    CreditCardPaymentListener, 
    SepaPaymentListener, 
    TicketListener]
