# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class AddDonationCampaignIdIndex < ActiveRecord::Migration
  def up
    Qx.execute(%(
      CREATE INDEX IF NOT EXISTS donations_campaign_id ON donations (campaign_id);
      CREATE INDEX IF NOT EXISTS donations_event_id ON donations (event_id);
    ))
  end

  def down
    Qx.execute(%(
        DROP INDEX IF EXISTS donations_campaign_id;
        DROP INDEX IF EXISTS donations_event_id;
      ))
  end
end
