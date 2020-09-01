class IndexDisputeStripeDisputeIdAsUnique < ActiveRecord::Migration
  def change
    add_index :disputes, :stripe_dispute_id, unique: true
  end
end
