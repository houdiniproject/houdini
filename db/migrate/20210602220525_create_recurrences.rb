class CreateRecurrences < ActiveRecord::Migration[6.1]
  def change
    create_table :recurrences, id: :string do |t|
      t.integer "amount", null: false
      t.references :recurring_donation, foreign_key: true, null: false
      t.references :supporter, foreign_key: true, null: false, id: :string
      t.datetime "start_date", comment: "the moment that the recurrence should start. Could be earlier than created_at if this was imported."
      t.timestamps
    end
  end
end
