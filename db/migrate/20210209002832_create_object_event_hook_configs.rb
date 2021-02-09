class CreateObjectEventHookConfigs < ActiveRecord::Migration[6.1]
  def change
    create_table :object_event_hook_configs do |t|
      t.string :webhook_service, null: false
      t.jsonb :configuration, null: false
      t.text :object_event_types, null: false

      t.references :nonprofit, index: true, foreign_key: true, null: false

      t.timestamps
    end
  end
end
