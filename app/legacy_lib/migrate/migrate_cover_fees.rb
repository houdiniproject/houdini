module Migrate
  class MigrateCoverFees
    def self.for_nonprofits
      MiscellaneousNpInfo.all.each do |mni|
        if (mni.hide_cover_fees)
          mni.fee_coverage_option_config = 'none'
        else
          mni.fee_coverage_option_config = nil
        end
        mni.save!
      end
    end

    def self.for_campaigns
      MiscCampaignInfo.all.each do |mci|
        if (mci.campaign.nonprofit.hide_cover_fees? )
          mci.fee_coverage_option_config = nil
        else
          if (mci.hide_cover_fees_option?)
            mci.fee_coverage_option_config = 'none'
          elsif (mci.manual_cover_fees?)
            mci.fee_coverage_option_config = 'manual'
          else
            mci.fee_coverage_option_config = nil
          end
        end
        mci.save!
      end
    end
  end
end