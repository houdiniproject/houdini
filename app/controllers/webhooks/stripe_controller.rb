module Webhooks
  class StripeController < ApplicationController
    def receive
      sig_header = request.headers['HTTP_STRIPE_SIGNATURE']
      event = nil
      begin
        payload = JSON.parse(request.raw_post)
        event = Stripe::Webhook.construct_event(
          request.raw_post, sig_header, ENV['STRIPE_WEBHOOK_SECRET']
        )
      rescue JSON::ParserError => e
        # Invalid payload
        render json: {error: "Invalid payload"}, status: 400
        return
      rescue Stripe::SignatureVerificationError => e
        # Invalid signature
        render json: {error: "Invalid signature"}, status: 400
        return 
      rescue => e
        render json: {error: "Unspecified error"}, status: 400
        return 
      end

      if ENV["RAILS_ENV"] != "production" || event.livemode
        StripeEvent.handle(event)
      end
      render json:{}, status: 200
    end

    def receive_connect
      sig_header = request.headers['HTTP_STRIPE_SIGNATURE']
      event = nil
      begin
        payload = JSON.parse(request.raw_post)
        event = Stripe::Webhook.construct_event(
          request.raw_post, sig_header, ENV['STRIPE_CONNECT_WEBHOOK_SECRET']
        )
      rescue JSON::ParserError => e
        # Invalid payload
        render json: {error: "Invalid payload"}, status: 400
        return
      rescue Stripe::SignatureVerificationError => e
        # Invalid signature
        render json: {error: "Invalid signature"}, status: 400
        return 
      rescue => e
        render json: {error: "Unspecified error"}, status: 400
        return 
      end

      if ENV["RAILS_ENV"] != "production" || event.livemode
        StripeEvent.handle(event)
      end
      render json:{}, status: 200
    end
  end
end
