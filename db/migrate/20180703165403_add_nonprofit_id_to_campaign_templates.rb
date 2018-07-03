class AddNonprofitIdToCampaignTemplates < ActiveRecord::Migration
  def change
    change_table :campaign_templates do |t|
      t.references :nonprofit
    end
  end
end
