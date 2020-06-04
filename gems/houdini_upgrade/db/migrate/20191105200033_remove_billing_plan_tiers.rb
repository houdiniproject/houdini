# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class RemoveBillingPlanTiers < ActiveRecord::Migration[5.2]
  def change
    remove_column :billing_plans, :tier, :integer
  end
end