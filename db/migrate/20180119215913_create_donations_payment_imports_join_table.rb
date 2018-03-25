# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class CreateDonationsPaymentImportsJoinTable < ActiveRecord::Migration
  def change
    create_table :donations_payment_imports, id: false do |t|
      t.references :donation
      t.references :payment_import
    end
  end
end
