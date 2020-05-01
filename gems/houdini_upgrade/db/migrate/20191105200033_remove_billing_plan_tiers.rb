class RemoveBillingPlanTiers < ActiveRecord::Migration[5.2]
  def change
    remove_column :billing_plans, :tier
  end
end
