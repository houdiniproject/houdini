# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module QueryCampaignMetrics

  def self.on_donations(campaign_id)


    Qx.select(
        "COALESCE(COUNT(DISTINCT donations.id), 0) AS supporters_count",
        "COALESCE(SUM(payments.gross_amount), 0) AS total_raised",
        "campaigns.goal_amount",
        "campaigns.show_total_count",
        "campaigns.show_total_raised",
        "campaigns_customizations.starting_point",
        "campaigns_customizations.show_supporters"
        )
      .from("campaigns")
      .left_join(
        ["donations", "donations.campaign_id=campaigns.id"],
        ["payments", "payments.donation_id=donations.id"],
        ["campaign_customizations", "campaign_customizations.campaign_id=campaigns.id"]
      )
      .where("campaigns.id=$id", id: campaign_id)
      .group_by('campaigns.id')
      .execute
      .last
  end
end


