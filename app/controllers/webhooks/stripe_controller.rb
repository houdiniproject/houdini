# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Webhooks
  class StripeController < ApplicationController
    rescue_from Exception, with: :unspecified_error
    rescue_from JSON::ParserError, with: :invalid_payload_error
    rescue_from Stripe::SignatureVerificationError, with: :signature_invalid_error

    def receive
      sig_header = request.headers["HTTP_STRIPE_SIGNATURE"]
      JSON.parse(request.raw_post)
      event = Stripe::Webhook.construct_event(
        request.raw_post, sig_header, ENV["STRIPE_WEBHOOK_SECRET"]
      )

      if ENV["RAILS_ENV"] != "production" || event.livemode
        StripeEvent.handle(event)
      end
      render json: {}, status: 200
    end

    def receive_connect
      sig_header = request.headers["HTTP_STRIPE_SIGNATURE"]
      JSON.parse(request.raw_post)
      event = Stripe::Webhook.construct_event(
        request.raw_post, sig_header, ENV["STRIPE_CONNECT_WEBHOOK_SECRET"]
      )

      if ENV["RAILS_ENV"] != "production" || event.livemode
        StripeEvent.handle(event)
      end
      render json: {}, status: 200
    end

    protected

    def invalid_payload_error(exception)
      render json: {error: "Invalid payload", details: exception.to_s, backtrace: exception.backtrace}, status: 400
    end

    def signature_invalid_error(exception)
      render json: {error: "Invalid signature", details: exception.to_s, backtrace: exception.backtrace}, status: 400
    end

    def unspecified_error(exception)
      if ENV["RAILS_ENV"] == "development"
        raise exception
      end
      render json: {error: "Unspecified error", details: exception.to_s, backtrace: exception.backtrace}, status: 400
    end
  end
end
