class CreateMiscPaymentInfos < ActiveRecord::Migration
  def change
    create_table :misc_payment_infos do |t|
      t.references :payment
      t.boolean :fee_covered
      t.timestamps
    end

    add_index :misc_payment_infos, :payment_id
  end
end
