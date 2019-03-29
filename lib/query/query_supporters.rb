# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'qexpr'
require 'psql'
require 'email'
require 'format/currency'
require 'format/csv'

module QuerySupporters

  # Query supporters and their donations and gift levels for a campaign
  def self.campaign_list_expr(np_id, campaign_id, query)
    expr = Qexpr.new.from('supporters')
     .left_outer_join('donations', 'donations.supporter_id=supporters.id')
     .left_outer_join('campaign_gifts', 'donations.id=campaign_gifts.donation_id')
     .left_outer_join('campaign_gift_options', 'campaign_gifts.campaign_gift_option_id=campaign_gift_options.id')
    .join_lateral(:payments,  Qx
                                  .select('payments.id, payments.gross_amount').from(:payments)
                                  .where('payments.donation_id = donations.id')
                                  .order_by('payments.created_at ASC')
                                  .limit(1).parse, true)
    .join(Qx.select('id, profile_id').from('campaigns')
    .where("id IN (#{QueryCampaigns
                          .get_campaign_and_children(campaign_id)
                               .parse})").as('campaigns').parse,
          'donations.campaign_id=campaigns.id')
    .join(Qx.select('users.id, profiles.id AS profiles_id, users.email')
            .from('users')
            .add_join('profiles', 'profiles.user_id = users.id')
            .as("users").parse, "users.profiles_id=campaigns.profile_id")
     .where("supporters.nonprofit_id=$id", id: np_id)
     .group_by('supporters.id')
     .order_by('MAX(donations.date) DESC')

		if query[:search].present?
      expr = expr.where(%Q(
         supporters.name ILIKE $search
      OR supporters.email ILIKE $search
      OR campaign_gift_options.name ILIKE $search
      ), search: '%' + query[:search] + '%')
    end
    return expr
  end


	# Used in the campaign donor listing
	def self.campaign_list(np_id, campaign_id, query)
    limit = 50
    offset = Qexpr.page_offset(limit, query[:page])

    data = Psql.execute(
      campaign_list_expr(np_id, campaign_id, query).select(
        'supporters.id',
        'supporters.name',
        'supporters.email',
        'SUM(payments.gross_amount) AS total_raised',
        'ARRAY_AGG(DISTINCT campaign_gift_options.name) AS campaign_gift_names',
        'DATE(MAX(donations.created_at)) AS latest_gift',
        'ARRAY_AGG(DISTINCT users.email) AS campaign_creator_emails'
      ).limit(limit).offset(offset)
    )

    total_count = Psql.execute(
      Qexpr.new.select("COUNT(s)")
      .from(campaign_list_expr(np_id, campaign_id, query).remove(:order_by).select('supporters.id').as('s').parse)
    ).first['count']

		return {
			data: data,
			total_count: total_count,
			remaining: Qexpr.remaining_count(total_count, limit, query[:page])
    }
	end

  def self.full_search_metrics(np_id, query)
    total_count = full_filter_expr(np_id, query)
      .select("COUNT(supporters)")
      .remove_clause(:order_by)
      .execute.first['count']

    return {
      total_count: total_count,
      remaining_count: Qexpr.remaining_count(total_count, 30, query[:page])
    }
  end

  # Full supporter search mainly for /nonprofits/id/supporters dashboard
  def self.full_search(np_id, query)
    select = [
      'supporters.name',
      'supporters.email',
      'supporters.is_unsubscribed_from_emails',
      'supporters.id AS id',
      'tags.names AS tags',
      "to_char(payments.max_date, 'MM/DD/YY') AS last_contribution",
      'payments.sum AS total_raised'
    ]
    if query[:select]
      select += query[:select].split(',')
    end

    supps = full_filter_expr(np_id, query)
      .select(*select)
      .paginate(query[:page].to_i, 30)
      .execute

    return { data: supps }
  end



  def self._full_search(np_id, query)
    select = [
        'supporters.name',
        'supporters.email',
        'supporters.is_unsubscribed_from_emails',
        'supporters.id AS id',
        'tags.names AS tags',
        "to_char(payments.max_date, 'MM/DD/YY') AS last_contribution",
        'payments.sum AS total_raised'
    ]
    if query[:select]
      select += query[:select].split(',')
    end

    supps = full_filter_expr(np_id, query)
                .select(*select)
                .paginate(query[:page].to_i, query[:page_length].to_i)
                .execute

    return { data: supps }
  end

  # # Given a list of supporters, you may want to remove duplicates from those supporters.
  # # @param [Enumerable[Supporter]] supporters
  # def self._remove_dupes_on_a_list_of_supporters(supporters, np_id)
  #
  #   new_supporters =supporters.clone.to_a
  #
  #   QuerySupporters.dupes_on_name_and_email(np_id).each{|duplicates|
  #     matched_in_group = false
  #     duplicates.each{|i|
  #       supporter = new_supporters.find{|s| s.id == i}
  #       if (supporter)
  #         if (matched_in_group)
  #           new_supporters.delete(supporter)
  #         else
  #           matched_in_group = true
  #         end
  #       end
  #     }
  #
  #   }
  #
  #   return new_supporters
  # end


  # Perform all filters and search for /nonprofits/id/supporters dashboard and export
  def self.full_filter_expr(np_id, query)
    payments_subquery =
        Qx.select("supporter_id", "SUM(gross_amount)", "MAX(date) AS max_date", "MIN(date) AS min_date", "COUNT(*) AS count")
      .from(
          Qx.select("supporter_id", "date", "gross_amount")
              .from(:payments)
              .join(Qx.select('id')
                        .from(:supporters)
                        .where("supporters.nonprofit_id = $id and deleted != 'true'", id: np_id )
                        .as("payments_to_supporters"),  "payments_to_supporters.id = payments.supporter_id"
              )
              .as("outer_from_payment_to_supporter")
              .parse)
      .group_by(:supporter_id)
      .as(:payments)

    tags_subquery = Qx.select("tag_joins.supporter_id", "ARRAY_AGG(tag_masters.id) AS ids", "ARRAY_AGG(tag_masters.name::text) AS names")
      .from(:tag_joins)
      .join(:tag_masters, "tag_masters.id=tag_joins.tag_master_id")
      .where("tag_masters.deleted IS NULL")
      .group_by("tag_joins.supporter_id")
      .as(:tags)

    expr = Qx.select('supporters.id').from(:supporters)
      .where(
        ["supporters.nonprofit_id=$id", id: np_id.to_i],
        ["supporters.deleted != true"]
      )
      .left_join(
         [tags_subquery, "tags.supporter_id=supporters.id"],
         [payments_subquery, "payments.supporter_id=supporters.id"]
        )
      .order_by('payments.max_date DESC NULLS LAST')

    if query[:last_payment_after].present?
      expr = expr.and_where("payments.max_date > $d", d: Chronic.parse(query[:last_payment_after]))
    end
    if query[:last_payment_before].present?
      expr = expr.and_where("payments.max_date < $d", d: Chronic.parse(query[:last_payment_before]))
    end
    if query[:first_payment_after].present?
      expr = expr.and_where("payments.min_date > $d", d: Chronic.parse(query[:first_payment_after]))
    end
    if query[:first_payment_before].present?
      expr = expr.and_where("payments.min_date < $d", d: Chronic.parse(query[:first_payment_before]))
    end
    if query[:total_raised_greater_than].present?
      expr = expr.and_where("payments.sum > $amount", amount: query[:total_raised_greater_than].to_i * 100)
    end
    if query[:total_raised_less_than].present?
      expr = expr.and_where("payments.sum < $amount OR payments.supporter_id IS NULL", amount: query[:total_raised_less_than].to_i * 100)
    end
    if ['week', 'month', 'quarter', 'year'].include? query[:has_contributed_during]
      d = Time.current.send('beginning_of_' + query[:has_contributed_during])
      expr = expr.and_where("payments.max_date >= $d", d: d)
    end
    if ['week', 'month', 'quarter', 'year'].include? query[:has_not_contributed_during]
      d = Time.current.send('beginning_of_' + query[:has_not_contributed_during])
      expr = expr.and_where("payments.count = 0 OR payments.max_date <= $d", d: d)
    end
    if query[:MAX_payment_before].present?
      date_ago = Timespan::TimeUnits[query[:MAX_payment_before]].utc
      expr = expr.and_where("payments.max_date < $date OR payments.count = 0", date: date_ago)
    end
    if query[:search].present?
      expr = expr.and_where(%Q(
         supporters.name ILIKE $search
      OR supporters.email ILIKE $search
      OR supporters.organization ILIKE $search
      ), search: '%' + query[:search] + '%')
    end
    if query[:notes].present?
      notes_subquery = Qx.select("STRING_AGG(content, ' ') as content, supporter_id")
        .from(:supporter_notes)
        .group_by(:supporter_id)
        .as(:notes)
      expr = expr.add_left_join(notes_subquery, "notes.supporter_id=supporters.id")
        .and_where("to_tsvector('english', notes.content) @@ plainto_tsquery('english', $notes)", notes: query[:notes])
    end
    if query[:custom_fields].present?
      c_f_subquery = Qx.select("STRING_AGG(value, ' ') as value", "supporter_id")
        .from(:custom_field_joins)
        .group_by("custom_field_joins.supporter_id")
        .as(:custom_fields)
      expr = expr.add_left_join(c_f_subquery, "custom_fields.supporter_id=supporters.id")
        .and_where("to_tsvector('english', custom_fields.value) @@ plainto_tsquery('english', $custom_fields)", custom_fields: query[:custom_fields])
    end
    if query[:location].present?
      expr = expr.and_where("lower(supporters.city) LIKE $city OR lower(supporters.zip_code) LIKE $zip", city: query[:location].downcase, zip: query[:location].downcase)
    end
    if query[:recurring].present?
      rec_ps_subquery = Qx.select("payments.count", "payments.supporter_id")
        .from(:payments)
        .where("kind='RecurringDonation'")
        .group_by("payments.supporter_id")
        .as(:rec_ps)
      expr = expr.add_left_join(rec_ps_subquery, "rec_ps.supporter_id=supporters.id")
        .and_where('rec_ps.count > 0')
    end
    if query[:ids].present?
      expr = expr.and_where("supporters.id IN ($ids)", ids: query[:ids].split(",").map(&:to_i))
    end
    if query[:select].present?
      expr = expr.select(*query[:select].split(",").map{|x| Qx.quote_ident(x)})
    end
    # Sort by supporters who have all of the list of tag names
    if query[:tags].present?
      tag_ids = (query[:tags].is_a?(String) ? query[:tags].split(',') : query[:tags]).map(&:to_i)
      expr = expr.and_where("tags.ids @> ARRAY[$tag_ids]", tag_ids: tag_ids)
    end
    if query[:campaign_id].present?
      expr = expr.add_join("donations", "donations.supporter_id=supporters.id AND donations.campaign_id IN (#{QueryCampaigns
      .get_campaign_and_children(query[:campaign_id].to_i)
           .parse})")
    end

    if query[:event_id].present?
      select_tickets_supporters = Qx.select("event_ticket_supporters.supporter_id")
                                     .from(
                                         "#{Qx.select("MAX(tickets.event_id) AS event_id", "tickets.supporter_id")
                                             .from(:tickets)
                                             .where("event_id = $event_id", event_id: query[:event_id])
                                             .group_by(:supporter_id).as('event_ticket_supporters').parse}"
                                     )

      select_donation_supporters =
          Qx.select("event_donation_supporters.supporter_id")
              .from(
                  "#{Qx.select("MAX(donations.event_id) AS event_id", "donations.supporter_id")
                      .from(:donations)
                      .where("event_id = $event_id", event_id: query[:event_id] )
                      .group_by(:supporter_id).as('event_donation_supporters').parse}")

      union_expr = "(
#{select_tickets_supporters.parse}
UNION DISTINCT
#{select_donation_supporters.parse}
) AS event_supporters"

      expr = expr
                 .add_join(
                     union_expr,
                     "event_supporters.supporter_id=supporters.id"
                 )
    end
    if ['asc', 'desc'].include? query[:sort_name]
      expr = expr.order_by(["supporters.name", query[:sort_name]])
    end
    if ['asc', 'desc'].include? query[:sort_contributed]
      expr = expr.and_where("payments.sum > 0").order_by(["payments.sum",  query[:sort_contributed]])
    end
    if ['asc', 'desc'].include? query[:sort_last_payment]
      expr = expr.order_by(["payments.max_date", "#{query[:sort_last_payment].upcase} NULLS LAST"])
    end
    return expr
  end

  def self.for_export_enumerable(npo_id, query, chunk_limit=35000)
    ParamValidation.new({npo_id: npo_id, query:query}, {npo_id: {required: true, is_int: true},
                                                        query: {required:true, is_hash: true}})

    return QxQueryChunker.for_export_enumerable(chunk_limit) do |offset, limit, skip_header|
      get_chunk_of_export(npo_id, query, offset, limit, skip_header)
    end

  end

  def self.get_chunk_of_export(np_id, query, offset=nil, limit=nil, skip_header=false)
    return QxQueryChunker.get_chunk_of_query(offset, limit, skip_header)  do
      expr = full_filter_expr(np_id, query)
      selects = supporter_export_selections.concat([
                                                       '(payments.sum / 100)::money::text AS total_contributed',
                                                       'supporters.id AS id'
                                                   ])
      if query[:export_custom_fields]
        # Add a select/csv-column for every custom field master for this nonprofit
        # and add a left join for every custom field master
        # eg if the npo has a custom field like Employer with id 99, then the query will be
        #   SELECT export_cfj_Employer.value AS Employer, ...
        #   FROM supporters
        #   LEFT JOIN custom_field_joins AS export_cfj_Employer ON export_cfj_Employer.supporter_id=supporters.id AND export_cfj_Employer.custom_field_master_id=99
        #   ...
        ids = query[:export_custom_fields].split(',').map(&:to_i)
        if ids.any?
          cfms = Qx.select("name", "id").from(:custom_field_masters).where(nonprofit_id: np_id).and_where("id IN ($ids)", ids: ids).ex
          cfms.compact.map do |cfm|
            table_alias = "cfjs_#{cfm['name'].gsub(/\$/, "")}"
            table_alias_quot = "\"#{table_alias}\""
            field_join_subq = Qx.select("STRING_AGG(value, ',') as value", "supporter_id")
                                  .from("custom_field_joins")
                                  .join("custom_field_masters" , "custom_field_masters.id=custom_field_joins.custom_field_master_id")
                                  .where("custom_field_masters.id=$id", id: cfm['id'])
                                  .group_by(:supporter_id)
                                  .as(table_alias)
            expr.add_left_join(field_join_subq, "#{table_alias_quot}.supporter_id=supporters.id")
            selects = selects.concat(["#{table_alias_quot}.value AS \"#{cfm['name']}\""])
          end
        end
      end


      get_last_payment_query = Qx.select('supporter_id', "MAX(date) AS date")
                                   .from(:payments)
                                   .group_by("supporter_id")
                                   .as("last_payment")

      expr.add_left_join(get_last_payment_query, 'last_payment.supporter_id = supporters.id')
      selects = selects.concat(['last_payment.date as "Last Payment Received"'])


      supporter_note_query = Qx.select("STRING_AGG(supporter_notes.created_at || ': ' || supporter_notes.content, '\r\n' ORDER BY supporter_notes.created_at DESC) as notes", "supporter_notes.supporter_id")
                                 .from(:supporter_notes)
                                 .group_by('supporter_notes.supporter_id')
                                 .as("supporter_note_query")

      expr.add_left_join(supporter_note_query, 'supporter_note_query.supporter_id=supporters.id')
      selects = selects.concat(["supporter_note_query.notes AS notes"]).concat(["ARRAY_TO_STRING(tags.names, ',') as tags"])


      expr.select(selects)
    end
  end

  def self.supporter_note_export_enumerable(npo_id, query, chunk_limit=35000)
    ParamValidation.new({npo_id: npo_id, query:query}, {npo_id: {required: true, is_int: true},
                                                        query: {required:true, is_hash: true}})

    return QxQueryChunker.for_export_enumerable(chunk_limit) do |offset, limit, skip_header|
      get_chunk_of_supporter_note_export(npo_id, query, offset, limit, skip_header)
    end

  end

  def self.get_chunk_of_supporter_note_export(np_id, query, offset=nil, limit=nil, skip_header=false)
    return QxQueryChunker.get_chunk_of_query(offset, limit, skip_header)  do
      expr = full_filter_expr(np_id, query)
      supporter_note_select = [
        'supporters.id',
        'supporters.email',
        'supporter_notes.created_at as "Note Created At"',
        'supporter_notes.content "Note Contents"'
      ]
      expr.add_join(:supporter_notes, 'supporter_notes.supporter_id = supporters.id')

      expr.select(supporter_note_select)
    end
  end

  # Give supp data for csv
  def self.for_export(np_id, query)
    expr = full_filter_expr(np_id, query)
    selects = supporter_export_selections.concat([
      '(payments.sum / 100)::money::text AS total_contributed',
      'supporters.id AS id'
    ])
    if query[:export_custom_fields]
      # Add a select/csv-column for every custom field master for this nonprofit
      # and add a left join for every custom field master
      # eg if the npo has a custom field like Employer with id 99, then the query will be 
      #   SELECT export_cfj_Employer.value AS Employer, ... 
      #   FROM supporters 
      #   LEFT JOIN custom_field_joins AS export_cfj_Employer ON export_cfj_Employer.supporter_id=supporters.id AND export_cfj_Employer.custom_field_master_id=99
      #   ...
      ids = query[:export_custom_fields].split(',').map(&:to_i)
      if ids.any?
        cfms = Qx.select("name", "id").from(:custom_field_masters).where(nonprofit_id: np_id).and_where("id IN ($ids)", ids: ids).ex
        cfms.compact.map do |cfm|
          table_alias = "cfjs_#{cfm['name'].gsub(/\$/, "")}"
          table_alias_quot = "\"#{table_alias}\""
          field_join_subq = Qx.select("STRING_AGG(value, ',') as value", "supporter_id")
            .from("custom_field_joins")
            .join("custom_field_masters" , "custom_field_masters.id=custom_field_joins.custom_field_master_id")
            .where("custom_field_masters.id=$id", id: cfm['id'])
            .group_by(:supporter_id)
            .as(table_alias)
          expr.add_left_join(field_join_subq, "#{table_alias_quot}.supporter_id=supporters.id")
          selects = selects.concat(["#{table_alias_quot}.value AS \"#{cfm['name']}\""])
        end
      end
    end
    supporter_note_query = Qx.select("STRING_AGG(supporter_notes.created_at || ': ' || supporter_notes.content, '\r\n' ORDER BY supporter_notes.created_at DESC) as notes", "supporter_notes.supporter_id")
      .from(:supporter_notes)
      .group_by('supporter_notes.supporter_id')
      .as("supporter_note_query")

    expr.add_left_join(supporter_note_query, 'supporter_note_query.supporter_id=supporters.id')
    selects = selects.concat(["supporter_note_query.notes AS notes"])

    expr.select(selects).execute(format: 'csv')
  end

  def self.supporter_export_selections
    [
      "substring(trim(both from supporters.name) from '^.+ ([^\s]+)$') AS \"Last Name\"",
      "substring(trim(both from supporters.name) from '^(.+) [^\s]+$') AS \"First Name\"",
      "trim(both from supporters.name) AS \"Full Name\"",
      "supporters.organization AS \"Organization\"",
      "supporters.email \"Email\"",
      "supporters.phone \"Phone\"",
      "supporters.address \"Address\"",
      "supporters.city \"City\"",
      "supporters.state_code \"State\"",
      "supporters.zip_code \"Postal Code\"",
      "supporters.country \"Country\"",
      "supporters.anonymous \"Anonymous?\"",
      "supporters.id \"Supporter ID\""
    ]
  end

  # Return an array of groups of ids, where sub-array is a  group of duplicates

  # Partial sql expression
  def self.dupes_expr(np_id)
    Qx.select("ARRAY_AGG(id) AS ids")
      .from(:supporters)
      .where("nonprofit_id=$id", id: np_id)
      .and_where("deleted='f' OR deleted IS NULL")
      .having('COUNT(id) > 1')
  end

  # Merge on exact supporter and email match

  # Find all duplicate supporters by the email column
  # returns array of arrays of ids
  # (each sub-array is a group of duplicates)
  def self.dupes_on_email(np_id)
    dupes_expr(np_id)
      .and_where("email IS NOT NULL")
      .and_where("email != ''")
      .group_by(:email)
      .execute(format: 'csv')[1..-1]
      .map(&:flatten)
  end

  # Find all duplicate supporters by the name column
  def self.dupes_on_name(np_id)
    dupes_expr(np_id)
      .and_where("name IS NOT NULL")
      .group_by(:name)
      .execute(format: 'csv')[1..-1]
      .map(&:flatten)
  end

  # Find all duplicate supporters that match on both name/email
  # @return [Array[Array]] an array containing arrays of the ids of duplicate supporters
  def self.dupes_on_name_and_email(np_id)
    dupes_expr(np_id)
      .and_where("name IS NOT NULL AND email IS NOT NULL AND email != ''")
      .group_by("name, email")
      .execute(format: 'csv')[1..-1]
      .map(&:flatten)
  end

  # Create an export that lists donors with their total contributed amounts
  # Underneath each donor, we separately list each individual payment
  # Only including payments for the given year
  def self.end_of_year_donor_report(np_id, year)
    supporter_expr = Qexpr.new
      .select( supporter_export_selections.concat(["(payments.sum / 100.0)::money::text AS \"Total Contributions #{year}\"", "supporters.id"]) )
      .from(:supporters)
      .join(Qexpr.new
        .select("SUM(gross_amount)", "supporter_id")
        .from(:payments)
        .group_by(:supporter_id)
        .where("date >= $date", date: "#{year}-01-01 00:00:00 UTC")
        .where("date < $date", date: "#{year+1}-01-01 00:00:00 UTC")
        .as(:payments), "payments.supporter_id=supporters.id")
      .where('payments.sum > 25000')
      .as('supporters')

    Psql.execute_vectors(
      Qexpr.new
      .select(
        "supporters.*",
        '(payments.gross_amount / 100.0)::money::text AS "Donation Amount"',
        'payments.date AS "Donation Date"',
        'payments.towards AS "Designation"'
      )
      .from(:payments)
      .join(supporter_expr, 'supporters.id = payments.supporter_id')
      .where('payments.nonprofit_id = $id', id: np_id)
      .where('payments.date >= $date', date: "#{year}-01-01 00:00:00 UTC")
      .where('payments.date < $date', date: "#{year+1}-01-01 00:00:00 UTC")
      .order_by("supporters.\"MAX Name\", payments.date DESC")
    )
  end


  # returns an array of common selects for supporters
  # which gets concated with an optional array of additional selects
  # used for merging supporters, crm profile and info card
  def self.profile_selects(arr = [])
     ["supporters.id",
      "supporters.name",
      "supporters.email",
      "supporters.address",
      "supporters.state_code",
      "supporters.city",
      "supporters.zip_code",
      "supporters.country",
      "supporters.organization",
      "supporters.phone"] + arr
  end


  # used on crm profile and info card
  def self.profile_payments_subquery 
    Qx.select("supporter_id", "SUM(gross_amount)", "COUNT(id) AS count")
      .from("payments")
      .group_by("supporter_id")
      .as("payments")
  end


  # Get a large set of detailed info for a single supporter, to be displayed in
  # the side panel details of the supporter listing after clicking a row.
  def self.for_crm_profile(npo_id, ids)
    selects = [
      "supporters.created_at",
      "supporters.imported_at",
      "supporters.anonymous AS anon",
      "supporters.is_unsubscribed_from_emails",
      "COALESCE(MAX(payments.sum), 0) AS raised",
      "COALESCE(MAX(payments.count), 0) AS payments_count",
      "COALESCE(COUNT(recurring_donations.active), 0) AS recurring_donations_count",
      "MAX(full_contact_infos.full_name) AS fc_full_name",
      "MAX(full_contact_infos.age) AS fc_age",
      "MAX(full_contact_infos.location_general) AS fc_location_general",
      "MAX(full_contact_infos.websites) AS fc_websites"]

    Qx.select(*QuerySupporters.profile_selects(selects))
      .from("supporters")
      .left_join(
        ["donations", "donations.supporter_id=supporters.id"],
        ["full_contact_infos", "full_contact_infos.supporter_id=supporters.id"],
        ["recurring_donations", "recurring_donations.donation_id=donations.id"],
        [QuerySupporters.profile_payments_subquery, "payments.supporter_id=supporters.id"])
      .group_by("supporters.id")
      .where("supporters.id IN ($ids)", ids: ids)
      .and_where("supporters.nonprofit_id = $id", id: npo_id)
      .execute
  end

  def self.for_info_card(id)
    selects = ["COALESCE(MAX(payments.sum), 0) AS raised"] 
    Qx.select(*QuerySupporters.profile_selects(selects))
      .from("supporters")
      .left_join([QuerySupporters.profile_payments_subquery, "payments.supporter_id=supporters.id"])
      .group_by("supporters.id")
      .where("supporters.id=$id", id: id)
      .execute.first
  end

  def self.merge_data(ids)
    Qx.select(*QuerySupporters.profile_selects)
      .from("supporters")
      .group_by("supporters.id")
      .where("supporters.id IN ($ids)", ids: ids.split(','))
      .execute
  end


  def self.year_aggregate_report(npo_id, time_range_params)
    npo_id = npo_id.to_i

    begin
      min_date, max_date = get_min_or_max_dates_for_range(time_range_params)
    rescue ArgumentError => e
      raise ParamValidation::ValidationError.new(e.message, {})
    end
    ParamValidation.new({npo_id: npo_id}, {
      npo_id: {required: true, is_integer: true}
    })
    aggregate_dons = %Q(
      array_to_string(
        array_agg(
          payments.date::date || ' ' ||
          (payments.gross_amount / 100)::text::money || ' ' ||
          coalesce(payments.kind, '') || ' ' ||
          coalesce(payments.towards, '')
          ORDER BY payments.date DESC
        ),
        '\n'
      ) AS "Payment History"
    )
    selects = supporter_export_selections.concat([
      "SUM(payments.gross_amount / 100)::text::money AS \"Total Payments\"",
      "MAX(payments.date)::date AS \"Last Payment Date\"",
      "AVG(payments.gross_amount / 100)::text::money AS \"Average Payment\"",
      aggregate_dons
    ])
    return Qx.select(selects)
      .from(:supporters)
      .join("payments", "payments.supporter_id=supporters.id AND payments.date::date >= $min_date AND payments.date::date < $max_date",:min_date => min_date.to_date, :max_date => max_date.to_date )
      .where('supporters.nonprofit_id=$id', id: npo_id)
      .group_by("supporters.id")
      .order_by("substring(trim(supporters.name) from '^.+ ([^\s]+)$')")
      .execute(format: 'csv')
  end


  def self.get_min_or_max_dates_for_range(time_range_params)
    begin
      if (time_range_params[:year])
        if (time_range_params[:year].is_a?(Integer))
          return DateTime.new(time_range_params[:year], 1, 1), DateTime.new(time_range_params[:year]+1, 1, 1)
        end
        if (time_range_params[:year].is_a?(String))
          wip = time_range_params[:year].to_i
          return DateTime.new(wip, 1, 1), DateTime.new(wip+1, 1, 1)
        end
      end
      if (time_range_params[:start])
        start = parse_convert_datetime(time_range_params[:start])
        if (time_range_params[:end])
          end_datetime = parse_convert_datetime(time_range_params[:end])
        end

        unless start.nil?
          return start, end_datetime ? end_datetime : start + 1.year
        end
      end
      raise ArgumentError.new("no valid time range provided")
    rescue
      raise ArgumentError.new("no valid time range provided")
    end

  end

  def self.tag_joins(nonprofit_id, supporter_id)
    Qx.select('tag_masters.id', 'tag_masters.name') 
      .from('tag_joins')
      .left_join('tag_masters', 'tag_masters.id = tag_joins.tag_master_id')
      .where(
        ['tag_joins.supporter_id = $id', id: supporter_id],
        ['coalesce(tag_masters.deleted, FALSE) = FALSE'],
        ['tag_masters.nonprofit_id = $id', id: nonprofit_id]
      )
      .execute
  end

  # this is inefficient, don't use in live code
  def self.find_supporters_with_multiple_recurring_donations_evil_way(npo_id)
    supporters = Supporter.where('supporters.nonprofit_id = ?', npo_id).includes(:recurring_donations)
    supporters.select{|s| s.recurring_donations.length > 1}
  end

  # this is inefficient, don't use in live code
  def self.find_supporters_with_multiple_active_recurring_donations_evil_way(npo_id)
    supporters = Supporter.where('supporters.nonprofit_id = ?', npo_id).includes(:recurring_donations)
    supporters.select{|s| s.recurring_donations.select{|rd| rd.active }.length > 1}
  end

  def self.parse_convert_datetime(date)
    if (date.is_a?(DateTime))
      return date
    end
    if (date.is_a?(Date))
      return date.to_datetime
    end
    if(date.is_a?(String))
      return DateTime.parse(date)
    end
  end
end

