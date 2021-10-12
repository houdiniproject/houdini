# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class BillingSubscriptionsController < ApplicationController
  include Controllers::Nonprofit::Current
  include Controllers::Nonprofit::Authorization

  before_action :authenticate_nonprofit_admin!

  def create
    @nonprofit ||= Nonprofit.find(params[:nonprofit_id])
    @subscription = BillingSubscription.create_with_stripe(@nonprofit, params[:billing_subscription])
    json_saved(@subscription, "Success! You are subscribed to #{Houdini.general.name}.")
  end

  # post /nonprofits/:nonprofit_id/billing_subscription/cancel
  def cancel
    @result = CancelBillingSubscription.with_stripe(@nonprofit)
    flash[:notice] = "Your subscription has been cancelled. We'll email you soon with exports."
    redirect_to root_url
  end

  # get nonprofits/:nonprofit_id/billing_subscription/cancellation
  def cancellation
    @nonprofit = current_nonprofit
    @billing_plan = @nonprofit.billing_plan
    @billing_subscription = @nonprofit.billing_subscription
  end
end
