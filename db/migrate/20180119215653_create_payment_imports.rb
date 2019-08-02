# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class CreatePaymentImports < ActiveRecord::Migration
  def change
    create_table :payment_imports do |t|
      t.references :user
      t.references :nonprofit

      t.timestamps
    end
  end
end
