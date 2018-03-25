class AddQueuedForImportAtToDonation < ActiveRecord::Migration
  def change
    add_column :donations, :queued_for_import_at, :datetime, default: nil
  end
end
