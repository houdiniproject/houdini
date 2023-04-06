class RemoveTierFromBillingPlan < ActiveRecord::Migration
  def change
    remove_column :billing_plans, :tier
  end
end
