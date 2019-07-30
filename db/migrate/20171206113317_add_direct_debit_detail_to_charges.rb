# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class AddDirectDebitDetailToCharges < ActiveRecord::Migration
  def change
    add_column :charges, :direct_debit_detail_id, :integer
  end
end
