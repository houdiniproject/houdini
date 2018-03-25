# Query code for both campaign_gift_options and campaign_gifts

require 'psql'

module QueryCampaignGifts


	# Create a mapping of: {
	# 'total_donations' => Integer, # total donations for gift options
	# 'total_one_time' => Integer, # total one-time donations for gift option
	# 'total_recurring' => Integer,
	# 'name' => String, # name of the gift level
	#
	# Includes the overall sum as well as the donations without gift options
	def self.report_metrics(campaign_id)

		data = Psql.execute(%Q(
			SELECT campaign_gift_options.name
				, COUNT(*) AS total_donations
				, SUM(ds_one_time.amount) AS total_one_time
				, SUM(ds_recurring.amount) AS total_recurring
			FROM donations AS ds
			LEFT OUTER JOIN donations ds_one_time
			ON ds_one_time.id=ds.id AND (ds.recurring IS NULL OR ds.recurring='f')
			LEFT OUTER JOIN donations ds_recurring
			ON ds_recurring.id=ds.id AND ds.recurring='t'
			LEFT OUTER JOIN campaign_gifts
			ON campaign_gifts.donation_id=ds.id
			LEFT OUTER JOIN campaign_gift_options
			ON campaign_gifts.campaign_gift_option_id=campaign_gift_options.id
			WHERE ds.campaign_id=#{Qexpr.quote(campaign_id)}
			GROUP BY campaign_gift_options.id
			ORDER BY total_donations DESC
		))

		return Hamster::Hash[data: data]
	end
end
