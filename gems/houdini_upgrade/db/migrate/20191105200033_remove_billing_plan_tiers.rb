# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class RemoveBillingPlanTiers < ActiveRecord::Migration[5.2]
  def change
    remove_column :billing_plans, :tier, :integer
  end
end
