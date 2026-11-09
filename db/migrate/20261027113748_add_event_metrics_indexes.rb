class AddEventMetricsIndexes < ActiveRecord::Migration[7.1]
  # Build the indexes without locking writes to the payments and tickets tables
  disable_ddl_transaction!

  def change
    add_index :tickets, [:event_id, :quantity, :checked_in], name: "idx_tickets_event_metrics", algorithm: :concurrently, if_not_exists: true
    add_index :tickets, [:payment_id, :event_id], name: "idx_tickets_payments", algorithm: :concurrently, if_not_exists: true
    add_index :payments, [:donation_id, :gross_amount], name: "idx_payments_donations", algorithm: :concurrently, if_not_exists: true
  end
end
