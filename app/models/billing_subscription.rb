# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class BillingSubscription < ApplicationRecord
  # :nonprofit_id, :nonprofit,
  # :billing_plan_id, :billing_plan,
  # :stripe_subscription_id,
  # :status # active, past_due, canceled, or unpaid

  attr_accessor :manual
  belongs_to :nonprofit
  belongs_to :billing_plan

  validates :nonprofit, presence: true
  validates :billing_plan, presence: true

  def as_json(options = {})
    h = super
    h[:plan_name] = billing_plan.name
    h[:plan_amount] = billing_plan.amount / 100
    h
  end
end
