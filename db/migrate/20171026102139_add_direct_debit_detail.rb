# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class AddDirectDebitDetail < ActiveRecord::Migration
  def change
    create_table :direct_debit_details do |t|
      t.string :iban
      t.string :account_holder_name
      t.string :bic
      t.belongs_to :supporter, index: true

      t.timestamps
    end

    add_column :donations,
      :direct_debit_detail_id,
      :integer,
      index: true,
      references: :direct_debit_details
  end
end
