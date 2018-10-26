# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class CreateCampaignCustomizations < ActiveRecord::Migration
  def change
    create_table :campaign_customizations do |t|
      t.references :campaigns
      t.boolean :show_donors
      t.integer :starting_donors
      t.timestamps
    end
  end
end
