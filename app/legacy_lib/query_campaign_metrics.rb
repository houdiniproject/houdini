# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module QueryCampaignMetrics
  def self.on_donations(campaign_id)
    campaign = Campaign.find(campaign_id)

    result = Psql.execute(
      Qexpr.new.select("COALESCE(COUNT(DISTINCT donations.id), 0) AS supporters_count",
        "COALESCE(SUM(payments.gross_amount), 0) AS total_raised")
        .from("campaigns")
        .join(
          "donations", "donations.campaign_id=campaigns.id"
        )
        .join_lateral("payments", QueryDonations.get_first_payment_for_donation.parse, true)
        .where("campaigns.id IN (#{QueryCampaigns
                                       .get_campaign_and_children(campaign_id)
                                       .parse})")
    ).last

    {
      "supporters_count" => result["supporters_count"],
      "total_raised" => result["total_raised"],
      "goal_amount" => campaign.goal_amount,
      "show_total_count" => campaign.show_total_count,
      "show_total_raised" => campaign.show_total_raised
    }
  end
end
