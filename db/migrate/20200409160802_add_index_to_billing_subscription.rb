class AddIndexToBillingSubscription < ActiveRecord::Migration
  def change
    add_index :billing_subscriptions, :nonprofit_id
    add_index :billing_subscriptions, [:nonprofit_id, :billing_plan_id]
  end
end
