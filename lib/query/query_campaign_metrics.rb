module QueryCampaignMetrics

  def self.on_donations(campaign_id)
    Qx.select(
        "COALESCE(COUNT(DISTINCT donations.id), 0) AS supporters_count",
        "COALESCE(SUM(payments.gross_amount), 0) AS total_raised",
        "campaigns.goal_amount",
        "campaigns.show_total_count",
        "campaigns.show_total_raised")
      .from("campaigns")
      .left_join(
        ["donations", "donations.campaign_id=campaigns.id"],
        ["payments", "payments.donation_id=donations.id"]
      )
      .where("campaigns.id=$id", id: campaign_id)
      .group_by('campaigns.id')
      .execute
      .last
  end
end


