class AddFeeCoverageOptionToMiscCampaignInfo < ActiveRecord::Migration
  def change
    add_column :misc_campaign_infos, :fee_coverage_option_config, :string, default: nil, nullable: true
    add_column :miscellaneous_np_infos, :fee_coverage_option_config, :string, default: nil, nullable: true
  end
end
