class CreateNonprofitVerificationProcessStatuses < ActiveRecord::Migration
  def change
    create_table :nonprofit_verification_process_statuses do |t|
      t.string :stripe_account_id, null:false
      t.datetime :started_at
      t.datetime :last_changed_from_pending_to_more_needed
      t.timestamps
    end

    add_index :nonprofit_verification_process_statuses, :stripe_account_id, unique: true, name: 'index_nonprofit_verification_to_stripe'
  end
end
