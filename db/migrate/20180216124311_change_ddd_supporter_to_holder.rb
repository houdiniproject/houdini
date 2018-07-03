# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class ChangeDddSupporterToHolder < ActiveRecord::Migration
  def change
    rename_column :direct_debit_details, :supporter_id, :holder_id
  end
end
