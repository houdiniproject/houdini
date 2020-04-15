class AddFkToCampaignGiftsToCampaignGiftOptions < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE campaign_gifts ADD CONSTRAINT campaign_gifts_to_option_fk FOREIGN KEY (campaign_gift_option_id) REFERENCES campaign_gift_options(id);
    SQL
  end

  def down
    execute <<-SQL
      ALTER TABLE campaign_gifts DROP CONSTRAINT campaign_gifts_to_option_fk;
    SQL
  end
end
