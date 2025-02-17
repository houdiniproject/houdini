# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class BillingPlan < ApplicationRecord
  # :name, #str: readable name
  # :tier, #int: 0-4 (0: Free, 1: Fundraising, 2: Supporter Management)
  # :amount, #int (cents)
  # :stripe_plan_id, #str (matches plan ID in Stripe) Not needed if it's not a paying subscription
  # :interval, #str ('monthly', 'annual')
  # :percentage_fee # 0.038

  Names = ["Starter", "Fundraising", "Supporter Management"].freeze
  DefaultAmounts = [0, 9900, 29_900].freeze # in pennies

  has_many :billing_subscriptions

  validates :name, presence: true
  validates :amount, presence: true
end
