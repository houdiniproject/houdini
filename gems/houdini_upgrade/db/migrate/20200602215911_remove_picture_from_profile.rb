# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class RemovePictureFromProfile < ActiveRecord::Migration[6.0]
  def change
    remove_column :profiles, :picture
  end
end
