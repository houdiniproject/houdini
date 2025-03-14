# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class CreateOfflineTransactionRefunds < ActiveRecord::Migration[6.1]
  def change
    create_table :offline_transaction_refunds, id: :string do |t|
      t.references :payment, foreign_key: true

      t.timestamps
    end
  end
end
