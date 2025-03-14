class CreateFullContact < ActiveRecord::Migration[6.0]
  def change
    create_table :full_contact_infos do |t|
      t.references :supporters
      t.string :email
      t.string :full_name
      t.string :gender
      t.string :city
      t.string :county
      t.string :state_code
      t.string :country
      t.string :continent
      t.string :age
      t.string :age_range
      t.string :location_general
      t.text :websites
      t.timestamps
    end

    create_table :full_contact_topics do |t|
      t.references :full_contact_infos
      t.string :provider
      t.string :value
      t.timestamps
    end

    create_table :full_contact_social_profiles do |t|
      t.references :full_contact_infos
      t.string :type_id
      t.string :username
      t.string :uid
      t.text :bio
      t.string :url
      t.integer :followers
      t.integer :following
      t.timestamps
    end

    create_table :full_contact_social_orgs do |t|
      t.references :full_contact_infos
      t.boolean :is_primary
      t.string :name
      t.date :start_date
      t.date :end_date
      t.string :title
      t.boolean :current
      t.timestamps
    end

    create_table :full_contact_social_photos do |t|
      t.references :full_contact_infos
      t.string :type_id
      t.boolean :is_primary
      t.text :url
      t.timestamps
    end

    create_table :full_contact_jobs do |t|
      t.references :supporter
      t.timestamps
    end
  end
end
