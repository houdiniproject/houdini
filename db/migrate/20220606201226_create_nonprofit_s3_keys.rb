class CreateNonprofitS3Keys < ActiveRecord::Migration
  def change
    create_table :nonprofit_s3_keys do |t|
      t.references :nonprofit, index: true
      t.string :access_key_id, required: true
      t.string :secret_access_key, required: true
      t.string :bucket_name, required: true
      t.string :region, required: true

      t.timestamps null: false
    end

    add_column :periodic_reports, :filename, :string
    add_reference :periodic_reports, :nonprofit_s3_key
  end
end
