class CreateMiscRecurringDonationInfos < ActiveRecord::Migration
  def change
    create_table :misc_recurring_donation_infos do |t|
      t.references :recurring_donation
      t.boolean :fee_covered
      t.timestamps
    end

    add_index :misc_recurring_donation_infos, :recurring_donation_id
  end
end
