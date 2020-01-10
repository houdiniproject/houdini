class CreateStripeEvents < ActiveRecord::Migration
  def change
    create_table :stripe_events do |t|
      t.string :object_id
      t.string :event_id
      t.datetime :event_time

      t.timestamps
    end
    add_index :stripe_events, :event_id

    add_index :stripe_events, [:object_id, :event_time]
  end
end
