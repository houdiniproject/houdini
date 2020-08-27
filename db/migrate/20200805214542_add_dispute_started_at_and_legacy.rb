class AddDisputeStartedAtAndLegacy < ActiveRecord::Migration
  def up
    add_column :disputes, :started_at, :datetime
    add_column :disputes, :is_legacy, :boolean, default: false

    Dispute.all.each do |d|
      d.started_at = d.created_at
      d.save!
    end
  end

  def down
    remove_column :disputes, :started_at
    remove_column :disputes, :is_legacy
  end
end
