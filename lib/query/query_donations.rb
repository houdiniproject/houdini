# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'query/query_supporters'

module QueryDonations

  # Export all donation data for a given campaign
	def self.campaign_export(campaign_id)
    Psql.execute_vectors(
      Qexpr.new.select([
        'donations.created_at',
				'(payments.gross_amount/100.00)::money::text AS amount',
				"COUNT(recurring_donations.id) > 0 AS recurring",
				"STRING_AGG(campaign_gift_options.name, ',') AS campaign_gift_names"
      ].concat(QuerySupporters.supporter_export_selections)
       .concat([
				 "supporters.id AS \"Supporter ID\"",
       ]).concat([
                            "coalesce(donations.designation, 'None') AS designation",
                            "#{QueryPayments.get_dedication_or_empty('type')}::text AS \"Dedication Type\"",
                            "#{QueryPayments.get_dedication_or_empty('name')}::text AS \"Dedicated To: Name\"",
                            "#{QueryPayments.get_dedication_or_empty('supporter_id')}::text AS \"Dedicated To: Supporter ID\"",
                            "#{QueryPayments.get_dedication_or_empty('contact', 'email')}::text AS \"Dedicated To: Email\"",
                            "#{QueryPayments.get_dedication_or_empty('contact', "phone")}::text AS \"Dedicated To: Phone\"",
                            "#{QueryPayments.get_dedication_or_empty( "contact", "address")}::text AS \"Dedicated To: Address\"",
                            "#{QueryPayments.get_dedication_or_empty(  "note")}::text AS \"Dedicated To: Note\"",
                            "donations.campaign_id AS \"Campaign Id\"",
                            "users.email AS \"Campaign Creator Email\""
                 ])
    ).from(:donations)
     .join(:supporters, "supporters.id=donations.supporter_id")
     .left_outer_join(:campaign_gifts, "campaign_gifts.donation_id=donations.id")
     .left_outer_join(:campaign_gift_options, "campaign_gift_options.id=campaign_gifts.campaign_gift_option_id")
     .left_outer_join(:recurring_donations, "recurring_donations.donation_id = donations.id")
     .join_lateral(:payments,
                   get_first_payment_for_donation.parse, true)
     .join(Qx.select('id, profile_id').from('campaigns')
              .where("id IN (#{QueryCampaigns
                                   .get_campaign_and_children(campaign_id)
                                   .parse})").as('campaigns').parse,
          'donations.campaign_id=campaigns.id')
     .join(Qx.select('users.id, profiles.id AS profiles_id, users.email')
              .from('users')
              .add_join('profiles', 'profiles.user_id = users.id')
              .as("users").parse, "users.profiles_id=campaigns.profile_id")
     .group_by("donations.id", "supporters.id", "payments.id", "payments.gross_amount", "users.email")
     .order_by("donations.date")
    )
	end

  def self.for_campaign_activities(id)
    QueryDonations.activities_expression(['donations.recurring'])
      .where("donations.campaign_id IN (#{QueryCampaigns
                                             .get_campaign_and_children(id)
                                             .parse})")
      .execute
  end

  def self.activities_expression(additional_selects)
    selects = ["
      CASE 
        WHEN donations.anonymous='t'
          OR supporters.anonymous='t'  
          OR supporters.name=''  
          OR supporters.name IS NULL 
        THEN 'A supporter' 
        ELSE supporters.name 
      END AS supporter_name", 
      "(donations.amount / 100.0)::money::text as amount", 
      "donations.date"] + (additional_selects ? additional_selects : [])

    return Qx.select(selects.join(','))
      .from(:donations)
      .left_join(:supporters, 'donations.supporter_id=supporters.id')
      .order_by("donations.date desc")
      .limit(15)
  end

  # Return an array of groups of offsite donation payment_ids that exactly match on nonprofit_id, supporter_id, amount, and date
  # !!! Note this returns the PAYMENT_IDS for each offsite donation
  def self.dupe_offsite_donations(np_id)
    payment_ids = Psql.execute_vectors(
      Qexpr.new.select("ARRAY_AGG(payments.id) AS ids")
      .from("donations")
      .join(:offsite_payments, "offsite_payments.donation_id=donations.id")
      .join(:payments, "payments.donation_id=donations.id")
      .where("donations.nonprofit_id=$id", id: np_id)
      .group_by("donations.supporter_id", "donations.amount", "donations.date")
      .having("COUNT(donations.id) > 1")
    )[1..-1].map(&:flatten)
  end

  def self.get_first_payment_for_donation(table_selector='donations')
    Qx.select('payments.id, payments.gross_amount').from(:payments)
        .where("payments.donation_id = #{table_selector}.id")
        .order_by('payments.created_at ASC')
        .limit(1)
  end

end
