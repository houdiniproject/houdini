module Migrate
  class MigrateCoverFees
    def self.for_nonprofits
      MiscellaneousNpInfo.all.each do |mni|
        mni.fee_coverage_option_config = if mni.hide_cover_fees
          "none"
        end
        mni.save!
      end
    end

    def self.for_campaigns
      MiscCampaignInfo.all.each do |mci|
        mci.fee_coverage_option_config = if mci.campaign.nonprofit.hide_cover_fees?
          nil
        elsif mci.hide_cover_fees_option?
          "none"
        elsif mci.manual_cover_fees?
          "manual"
        end
        mci.save!
      end
    end
  end
end
