class CreateNonprofitDeactivations < ActiveRecord::Migration
  def change
    create_table :nonprofit_deactivations do |t|
      t.references :nonprofit
      t.boolean :deactivated

      t.timestamps
    end
  end
end
