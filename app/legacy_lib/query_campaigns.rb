# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

module QueryCampaigns
  def self.featured(limit, gross_more_than)
    expr = Qexpr.new.select(
      "campaigns.name",
      "campaigns.summary",
      "campaigns.gross",
      Image._url("campaigns", "main_image", "normal") + "AS main_image_url",
      "concat('/nonprofits/', campaigns.nonprofit_id, '/campaigns/', campaigns.id) AS url"
    ).from(
      Qexpr.new.select("campaigns.*", "SUM(donations.amount) AS gross")
      .from("campaigns")
      .join("donations", "donations.campaign_id=campaigns.id")
      .group_by("campaigns.id"),
      "campaigns"
    ).where("campaigns.gross > $amount AND campaigns.published='t' AND campaigns.nonprofit_id!=$id", amount: gross_more_than, id: 4182)
      .order_by("campaigns.updated_at ASC")
      .limit(limit)

    Psql.execute(expr.parse)
  end

  def self.timeline(campaign_id)
    ex = QueryCampaigns.payments_expression(campaign_id, true)
    ex.group_by("DATE(payments.date)")
      .order_by("DATE(payments.date)")
      .execute
  end

  def self.payments_expression(campaign_id, for_timeline)
    selects = [
      "coalesce(SUM(payments.gross_amount), 0) AS total_cents",
      "coalesce(SUM(recurring.gross_amount), 0) AS recurring_cents",
      "coalesce(SUM(offsite.gross_amount), 0) AS offsite_cents",
      "coalesce(SUM(onetime.gross_amount), 0) AS onetime_cents"
    ]

    for_timeline ?
      selects.push("MAX(DATE(payments.date)) AS date") :
      selects.push("coalesce(count(supporters.id), 0) AS supporters_count")

    Qx.select(*selects)
      .from("payments")
      .left_join(
        ["donations", "payments.donation_id=donations.id"],
        ["payments AS onetime", "onetime.id=payments.id AND onetime.kind='Donation'"],
        ["payments AS offsite", "offsite.id=payments.id AND offsite.kind='OffsitePayment'"],
        ["payments AS recurring", "recurring.id=payments.id AND recurring.kind='RecurringDonation'"]
      )
      .where("donations.campaign_id IN (#{QueryCampaigns.get_campaign_and_children(campaign_id).parse})")
  end

  def self.totals(campaign_id)
    ex = QueryCampaigns.payments_expression(campaign_id, false)
    ex.add_left_join(["supporters", "donations.supporter_id=supporters.id"])
      .execute.first
  end

  def self.name_and_id(npo_id)
    np = Nonprofit.find(npo_id)
    campaigns = np.campaigns.not_deleted.includes(:profile).order("campaigns.name ASC")
    campaigns.map do |i|
      {
        "name" => i.name,
        "id" => i.id,
        "isChildCampaign" => i.child_campaign?,
        "creator" => i.profile&.name || "user ##{i.profile.id}"
      }
    end
  end

  def self.get_campaign_and_children(campaign_id)
    Qx.select("id")
      .from("campaigns")
      .where("campaigns.id = $id OR campaigns.parent_campaign_id=$id",
        id: campaign_id)
  end
end
