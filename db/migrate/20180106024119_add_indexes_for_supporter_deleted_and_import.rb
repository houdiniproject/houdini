# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class AddIndexesForSupporterDeletedAndImport < ActiveRecord::Migration
  def change
    add_index :supporters, :deleted
    add_index :supporters, :import_id
  end
end
