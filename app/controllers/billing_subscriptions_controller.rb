# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class BillingSubscriptionsController < ApplicationController
  include Controllers::NonprofitHelper

  before_action :authenticate_nonprofit_admin!

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
