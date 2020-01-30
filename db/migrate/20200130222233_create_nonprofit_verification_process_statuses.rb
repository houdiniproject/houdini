class CreateNonprofitVerificationProcessStatuses < ActiveRecord::Migration
  def change
    create_table :nonprofit_verification_process_statuses do |t|
      t.references :nonprofit
      t.datetime :started_at
      t.timestamps
    end
  end
end
