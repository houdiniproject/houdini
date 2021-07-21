class AddFlatPlatformFeeToBillingPlan < ActiveRecord::Migration
  def change
    add_column :billing_plans, :flat_fee, :integer, default: 0, null: false
  end
end
