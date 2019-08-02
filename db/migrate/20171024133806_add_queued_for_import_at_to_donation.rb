# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class AddQueuedForImportAtToDonation < ActiveRecord::Migration
  def change
    add_column :donations, :queued_for_import_at, :datetime, default: nil
  end
end
