class AddDonationCampaignIdIndex < ActiveRecord::Migration
  def up
    Qx.execute(%Q(
      CREATE INDEX IF NOT EXISTS donations_campaign_id ON donations (campaign_id);
      CREATE INDEX IF NOT EXISTS donations_event_id ON donations (event_id);
    ))
  end
  def down
      Qx.execute(%Q(
        DROP INDEX IF EXISTS donations_campaign_id;
        DROP INDEX IF EXISTS donations_event_id;
      ))
  end
end
