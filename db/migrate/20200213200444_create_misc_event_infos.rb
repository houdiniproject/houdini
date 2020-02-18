class CreateMiscEventInfos < ActiveRecord::Migration
  def change
    create_table :misc_event_infos do |t|
      t.references :event
      t.boolean :hide_cover_fees_option

      t.timestamps
    end
  end
end
