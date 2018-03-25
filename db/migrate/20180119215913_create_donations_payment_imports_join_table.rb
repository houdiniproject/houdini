class CreateDonationsPaymentImportsJoinTable < ActiveRecord::Migration
  def change
    create_table :donations_payment_imports, id: false do |t|
      t.references :donation
      t.references :payment_import
    end
  end
end
