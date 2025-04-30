class CreateObjectEvents < ActiveRecord::Migration
  def change
    create_table :object_events do |t|
      t.references :event_entity, {polymorphic: true, index: true}
      t.index :event_entity_type
      t.string :event_type, {index: true}
      t.string :event_entity_houid, {index: true}
      t.references :nonprofit, {index: true}
      t.string :houid, {index: true}
      t.datetime :created
      t.jsonb :object_json
      t.timestamps null: false
    end
  end
end
