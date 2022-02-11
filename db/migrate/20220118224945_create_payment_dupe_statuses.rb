class CreatePaymentDupeStatuses < ActiveRecord::Migration
  def change
    create_table :payment_dupe_statuses do |t|
      t.belongs_to :payment, index: true
      t.boolean :matched, default: false

      t.timestamps null: false
    end
  end
end
