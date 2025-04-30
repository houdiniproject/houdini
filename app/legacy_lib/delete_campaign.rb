# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module DeleteCampaign
  # This is NOT recommended. We only do this in special cases as campaigns
  # should never be totally deleted, only "hidden"
  def self.delete(campaign)
    if safe_to_delete?(campaign)
      campaign.destroy
    end
  end

  def self.safe_to_delete?(campaign)
    campaign.payments.none? && campaign.donations.none? && campaign.activities.none? && (campaign.child_campaign? || campaign.children_campaigns.none?)
  end
end
