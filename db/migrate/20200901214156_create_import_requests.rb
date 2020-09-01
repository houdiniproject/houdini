class CreateImportRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :import_requests do |t|
      t.jsonb :header_matches
      t.references :nonprofit
      t.string :user_email

      t.timestamps
    end
  end
end
