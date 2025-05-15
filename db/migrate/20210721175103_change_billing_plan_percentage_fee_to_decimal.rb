class ChangeBillingPlanPercentageFeeToDecimal < ActiveRecord::Migration
  def change
    change_column :billing_plans, :percentage_fee, :decimal, null: false, default: 0
  end
end
