# frozen_string_literal: true

class RegisterNonprofitAndUser::SetupBillingSubscription < Actor
  input :nonprofit

  def call
    billing_plan = ::BillingPlan.find(Settings.default_bp.id)
    b_sub = nonprofit.build_billing_subscription(billing_plan: billing_plan, status: 'active')
    b_sub.save!
  end
end
