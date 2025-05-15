# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# Query code for both campaign_gift_options and campaign_gifts

require "psql"

module QueryCampaignGifts
  # Create a mapping of: {
  # 'total_donations' => Integer, # total donations for gift options
  # 'total_one_time' => Integer, # total one-time donations for gift option
  # 'total_recurring' => Integer,
  # 'name' => String, # name of the gift level
  #
  # Includes the overall sum as well as the donations without gift options

  # NOTE: this doesn't include campaign gift options if they don't have any donations. Why? Bad design, I think.
  def self.report_metrics(campaign_id)
    data = Psql.execute(%(
			SELECT campaign_gift_options.name
				, COUNT(*) AS total_donations
				, SUM(ds_one_time.amount) AS total_one_time
				, SUM(ds_recurring.amount) AS total_recurring
			FROM (#{donations_for_campaign(campaign_id).parse}) AS ds
			LEFT OUTER JOIN (#{get_corresponding_payments(campaign_id, %(LEFT OUTER JOIN recurring_donations ON recurring_donations.donation_id = donations.id
                          ), %(WHERE recurring_donations.id IS NULL))}) ds_one_time
			ON ds_one_time.id = ds.id
			LEFT OUTER JOIN (#{get_corresponding_payments(campaign_id, %(INNER JOIN recurring_donations ON recurring_donations.donation_id = donations.id))}) ds_recurring
					ON ds_recurring.id = ds.id
			LEFT OUTER JOIN campaign_gifts
			ON campaign_gifts.donation_id=ds.id
			LEFT OUTER JOIN campaign_gift_options
			ON campaign_gifts.campaign_gift_option_id=campaign_gift_options.id
			GROUP BY campaign_gift_options.id
			ORDER BY total_donations DESC
		))

    {data: data}
  end

  def self.donations_for_campaign(campaign_id)
    Qx.select("donations.id, donations.amount").from(:donations).where("campaign_id IN ($ids)", {ids: QueryCampaigns.get_campaign_and_children(campaign_id)})
  end

  def self.get_corresponding_payments(campaign_id, recurring_clauses, where_clauses = "")
    %(SELECT donations.id, payments.gross_amount AS amount
			FROM (#{donations_for_campaign(campaign_id).parse}) donations
				#{recurring_clauses}
			JOIN LATERAL (
				SELECT payments.id, payments.gross_amount, payments.donation_id, payments.created_at FROM payments
				WHERE payments.donation_id = donations.id
				ORDER BY payments.created_at ASC
				LIMIT 1
			) payments ON true
			#{where_clauses}
		)
  end
end
