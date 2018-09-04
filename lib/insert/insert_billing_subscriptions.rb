# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'qx'
require 'delayed_job_helper'
require 'active_support/core_ext'


module InsertBillingSubscriptions

  def self.trial(np_id, stripe_plan_id)
    begin
      nonprofit = Nonprofit.includes(:billing_subscription).find(np_id)
      billing_plan = BillingPlan.where('stripe_plan_id = ?', stripe_plan_id).last
      sub = nonprofit.create_billing_subscription(billing_plan: billing_plan, status: 'trialing')
      n = 10
      DelayedJobHelper.enqueue_job(self, :check_trial, [sub['id']], {run_at: n.days.from_now})
      return {json: sub}
    rescue ActiveRecord::RecordNotFound => e
      return {json: { error: e }, status: :unprocessable_entity}
    end

  end

  def self.check_trial(bs_id)
    sub = Qx.fetch(:billing_subscriptions, bs_id).last
    if sub['status'] == 'trialing'
      Qx.update(:billing_subscriptions)
        .set(status: 'inactive')
        .timestamps
        .where("id = $id", id: bs_id)
        .execute
    end
  end

end
