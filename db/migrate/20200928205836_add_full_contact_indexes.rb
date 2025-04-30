class AddFullContactIndexes < ActiveRecord::Migration
  def change
    add_index :full_contact_photos, [:full_contact_info_id, :is_primary], name: "index_full_context_photo_info_primary"
    add_index :full_contact_orgs, :full_contact_info_id
    add_index :full_contact_topics, :full_contact_info_id
    add_index :full_contact_social_profiles, :full_contact_info_id
    add_index :full_contact_infos, :supporter_id
  end
end
