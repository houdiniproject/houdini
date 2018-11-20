# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module QueryCampaignMetrics

  def self.on_donations(campaign_id)
    campaign = Campaign.find(campaign_id)

    result = Qx.select(
        "COALESCE(COUNT(DISTINCT donations.id), 0) AS supporters_count",
        "COALESCE(SUM(payments.gross_amount), 0) AS total_raised"
         )
      .from("campaigns")
      .join(
        ["donations", "donations.campaign_id=campaigns.id"],
        ["payments", "payments.donation_id=donations.id"]
      )
      .where("campaigns.id IN (#{Qx.select("id").from('campaigns')
                    .where("campaigns.id = $id OR campaigns.parent_campaign_id=$id", id: campaign_id).parse
      })")
      .execute
      .last

    return {
        'supporters_count' => result['supporters_count'],
        'total_raised'=> result['total_raised'],
        'goal_amount'=> campaign.goal_amount,
        'show_total_count'=> campaign.show_total_count,
        'show_total_raised'=> campaign.show_total_raised
    }
  end
end


