class RemoveProfilesPrivacySettings < ActiveRecord::Migration
  def change
    remove_column :profiles, :privacy_settings
  end
end
