module Nonprofits
  class StripeAccountsController < ApplicationController
    include Controllers::NonprofitHelper
    before_action :authenticate_nonprofit_admin!

    layout "layouts/apified"

    def index
      render_json do
        raise ActiveRecord::RecordNotFound unless current_nonprofit.stripe_account

        current_nonprofit.stripe_account.to_json(except: [:object, :id, :created_at, :updated_at], methods: [:verification_status, :deadline])
      end
    end

    # this is the start page when someone needs to verify their nonprofit
    def verification
      @theme = "minimal"
      @current_nonprofit = current_nonprofit
    end

    # html page where we check repeatedly whether we received a verification update
    def confirm
      @theme = "minimal"
      @current_nonprofit = current_nonprofit
    end

    def begin_verification
      StripeAccountUtils.find_or_create(current_nonprofit.id)
      current_nonprofit.reload

      status = NonprofitVerificationProcessStatus.where("stripe_account_id = ?", current_nonprofit.stripe_account_id).first
      status ||= NonprofitVerificationProcessStatus.new(stripe_account_id: current_nonprofit.stripe_account_id)

      unless status.started_at
        status.started_at = DateTime.now
      end

      status.save!

      render json: {}, status: :ok
    end

    # html page when a link failed
    def retry
      @theme = "minimal"
      @current_nonprofit = current_nonprofit
    end

    def account_link
      StripeAccountUtils.find_or_create(current_nonprofit.id)
      current_nonprofit.reload

      if current_nonprofit.stripe_account_id
        render json: Stripe::AccountLink.create({
          account: current_nonprofit.stripe_account_id,
          refresh_url: nonprofits_stripe_account_url(current_nonprofit.id, {return_location: params[:return_location]}),
          return_url: confirm_nonprofits_stripe_account_url(current_nonprofit.id, {return_location: params[:return_location]}),
          type: "account_onboarding",
          collection_options: {
            fields: "eventually_due",
            future_requirements: "include"
          }
        }).to_json, status: 200
      else
        render json: {error: "No Stripe account could be found or created. Please contact support@commitchange.com for assistance."}, status: 400
      end
    end
  end
end
