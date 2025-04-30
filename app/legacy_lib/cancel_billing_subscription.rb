# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module CancelBillingSubscription
  # @param [Nonprofit] nonprofit
  # @return [BillingSubscription] new billing subscription for the nonprofit
  def self.with_stripe(nonprofit)
    begin
      ParamValidation.new({nonprofit: nonprofit}, {
        nonprofit: {required: true, is_a: Nonprofit}
      })
    rescue ParamValidation::ValidationError => e
      return {json: {error: "Validation error\n #{e.message}", errors: e.data}, status: :unprocessable_entity}
    end

    np_card = nonprofit.active_card
    billing_subscription = nonprofit.billing_subscription
    return {json: {error: "We don't have a subscription for your non-profit. Please contact support."}, status: :unprocessable_entity} if np_card.nil? || billing_subscription.nil? # stripe_customer_id on Card object

    # Cancel and delete the subscription on Stripe
    begin
      customer = Stripe::Customer.retrieve(np_card.stripe_customer_id)
      stripe_subscription = customer.subscriptions.retrieve(billing_subscription.stripe_subscription_id)
      stripe_subscription.delete(at_period_end: false)
    rescue Stripe::StripeError => e
      return {json: {error: "Oops! There was an error processing your subscription cancellation. Error: #{e}"}, status: :unprocessable_entity}
    end

    billing_plan_id = Settings.default_bp.id
    billing_subscription.update_attributes({
      billing_plan_id: billing_plan_id,
      status: "active"
    })

    BillingSubscription.clear_cache(nonprofit)
    {json: {}, status: :ok}
  end
end
