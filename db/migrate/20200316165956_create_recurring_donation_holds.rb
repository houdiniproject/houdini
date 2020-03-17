class CreateRecurringDonationHolds < ActiveRecord::Migration
  def change
    create_table :recurring_donation_holds do |t|
      t.references :recurring_donation
      t.datetime :end_date
      t.timestamps
    end
  end
end
