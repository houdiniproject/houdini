# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

module QueryPayments


  def self.get_nonprofit_query(npo_id)
    Qexpr.new.select("*").from(:nonprofits).where("id = $id", id: npo_id).limit(1)
  end

  def self.get_nonprofit_payments_query(npo_id)
    Qexpr.new.select("*").from(:payments).where("nonprofit_id = $id", id: npo_id)
  end

  # Fetch all payments connected to available charges, undisbursed refunds or lost disputes
  # Ids For Payouts collects all payments where:
  # *they have a connected charge, refund or dispute (CRD), i.e. the CRD's payment_id is not NULL and represents a record in payments
  # * If the CRD is a refund, then it has a corresponding payment_id and the disbursed is NULL OR the disbursed is marked as false 'f'
  # * If the CRD is a charge, the status is set to available
  # * If the CRD is a dispute, the status is set to lost ('lost' means the money was refunded to the customer)
  #
  # In all cases (I think), a corresponding payment for a CRD should exist with the appropriate change in the nonprofit's balance included. This means:
  # * For charges, gross_amount should be positive since we're increasing the nonprofit's balance
  # * For refunds and disputes, the gross_amount should be negative since we're decreasing the nonprofit's balance
  #
  # In effect, we're getting the list of payments which haven't been paid out in a some fashion. This is not a great design but it works mostly.
  def self.ids_for_payout(npo_id, options={})
    end_of_day = (Time.current + 1.day).beginning_of_day
    Qx.select('DISTINCT payments.id')
        .from(:payments)
        .left_join(:charges, 'charges.payment_id=payments.id')
        .add_left_join(:refunds, 'refunds.payment_id=payments.id')
        .add_left_join(:dispute_transactions, 'dispute_transactions.payment_id=payments.id')
        .add_left_join(:manual_balance_adjustments, "manual_balance_adjustments.payment_id=payments.id")
        .where('payments.nonprofit_id=$id', id: npo_id)
        .and_where("refunds.payment_id IS NOT NULL OR charges.payment_id IS NOT NULL OR dispute_transactions.payment_id IS NOT NULL OR manual_balance_adjustments.payment_id IS NOT NULL")
        .and_where(%Q(
        ((refunds.payment_id IS NOT NULL AND refunds.disbursed IS NULL) OR refunds.disbursed='f')
        OR (charges.status='available')
        OR (dispute_transactions.disbursed='f'
        OR (NOT manual_balance_adjustments.disbursed))
       ))
        .and_where("payments.date <= $date", date: options[:date] || end_of_day)
        .execute.map{|h| h['id']}
  end

  # the amount to payout calculates the total payout based upon the payments it's provided, likely provided from ids_to_payout
  def self.get_payout_totals(payment_ids)
    return {'gross_amount' => 0, 'fee_total' => 0, 'net_amount' => 0} if payment_ids.empty?
    Qx.select(
      'SUM(payments.gross_amount) AS gross_amount',
      'SUM(payments.fee_total) AS fee_total',
      'SUM(payments.net_amount) AS net_amount',
      'COUNT(payments.*) AS count')
      .from(:payments)
      .where("payments.id IN ($ids)", ids: payment_ids)
      .execute.first
  end

  


  def self.nonprofit_balances(npo_id)
    payout_totals = QueryPayments.get_payout_totals(QueryPayments.ids_for_payout(npo_id))
    
    pending = Nonprofit.find(npo_id).payments.pending_totals
    {
      'available' => {'net' => payout_totals['net_amount'] || 0, 'gross' => payout_totals['gross_amount'] || 0},
      'pending' => {'net' => pending['net'] || 0, 'gross' => pending['gross'] || 0}
      }
  end


  def self.full_search(npo_id, query)
    limit = 30
    offset = Qexpr.page_offset(limit, query[:page])
    expr = full_search_expr(npo_id, query).select(
      'payments.kind',
      'payments.towards',
      'payments.id AS id',
      'supporters.name',
      'supporters.email',
      'payments.gross_amount',
      'timezone(
        COALESCE(nonprofits.timezone, \'UTC\'),
        timezone(\'UTC\', payments.date)
      ) as date'
    )

    payments = Psql.execute(expr.limit(limit).offset(offset).parse)

    totals_query = expr
      .remove(:select)
      .remove(:order_by)
      .select(
        'COALESCE(COUNT(payments.id), 0) AS count', 
        'COALESCE((SUM(payments.gross_amount)  / 100.0), 0)::money::text AS amount')

    totals = Psql.execute(totals_query).first

    return {
      data: payments,
      total_count: totals['count'],
      total_amount: totals['amount'],
      remaining: Qexpr.remaining_count(totals['count'], limit, query[:page])
    }

  end


  # we must provide payments.*, supporters.*, donations.*, associated event_id, associated campaign_id
  def self.full_search_expr(npo_id, query)
    expr = Qexpr.new.from('payments')
          .inner_join('supporters', "supporters.id=payments.supporter_id")
          .inner_join('nonprofits', 'nonprofits.id=payments.nonprofit_id')
          .left_outer_join('donations', 'donations.id=payments.donation_id' )
    .join("(#{select_to_filter_search(npo_id, query)}) AS \"filtered_payments\"", 'payments.id = filtered_payments.id')
    .order_by('payments.date DESC')

    if ['asc', 'desc'].include? query[:sort_amount]
      expr = expr.order_by("payments.gross_amount #{query[:sort_amount]}")
    end
    if ['asc', 'desc'].include? query[:sort_date]
      expr = expr.order_by("payments.date #{query[:sort_date]}")
    end
    if ['asc', 'desc'].include? query[:sort_name]
      expr = expr.order_by("coalesce(NULLIF(supporters.name, ''), NULLIF(supporters.email, '')) #{query[:sort_name]}")
    end
    if ['asc', 'desc'].include? query[:sort_type]
      expr = expr.order_by("payments.kind #{query[:sort_type]}")
    end
    if ['asc', 'desc'].include? query[:sort_towards]
      expr = expr.order_by("NULLIF(payments.towards, '') #{query[:sort_towards]}")
    end

    expr = expr.with(:nonprofits, get_nonprofit_query(npo_id), materialized: true)
    expr = expr.with(:payments, get_nonprofit_payments_query(npo_id), materialized: false)

    return expr
  end

  # perform the search but only get the relevant payment_ids
  def self.select_to_filter_search(npo_id, query)
    inner_donation_search = Qexpr.new.select('donations.*').from('donations')
    if (query[:event_id].present?)
      inner_donation_search = inner_donation_search.where('donations.event_id=$id', id: query[:event_id])
    end
    if (query[:campaign_id].present?)
      campaign_search = campaign_and_child_query_as_raw_string
      inner_donation_search = inner_donation_search.where("donations.campaign_id IN (#{campaign_search})", id: query[:campaign_id])
    end

    # We are including deleted supporters on this query because deleted supporters may have made
    # payments.
    expr = Qexpr.new.select('payments.id').from('payments')
          .inner_join('supporters', "supporters.id=payments.supporter_id")
          .inner_join('nonprofits', 'nonprofits.id=payments.nonprofit_id')
          .left_outer_join(inner_donation_search.as('donations'), 'donations.id=payments.donation_id' )
          .where('payments.nonprofit_id=$id', id: npo_id.to_i)

    if query[:ids].present?
      if query[:ids].is_a? String
        query[:ids] = query[:ids].split(',')
      end
      if query[:ids].is_a?(Array) && query[:ids].all?{|i| i.to_i != 0}
        expr = expr.where("payments.id IN ($ids)", ids: query[:ids])
      end
    end    
    if query[:search].present?
      expr = SearchVector.query(query[:search], expr)
    end
    # Fix for failed payment queries when filtering by campaign AND adding a sort
    unless (query[:campaign_id].present? || query[:event_id].present?) # if we need to add the reverse query, we can't add this here.
      if ['asc', 'desc'].include? query[:sort_amount]
        expr = expr.order_by("payments.gross_amount #{query[:sort_amount]}")
      end
      if ['asc', 'desc'].include? query[:sort_date]
        expr = expr.order_by("payments.date #{query[:sort_date]}")
      end
      if ['asc', 'desc'].include? query[:sort_name]
        expr = expr.order_by("coalesce(NULLIF(supporters.name, ''), NULLIF(supporters.email, '')) #{query[:sort_name]}")
      end
      if ['asc', 'desc'].include? query[:sort_type]
        expr = expr.order_by("payments.kind #{query[:sort_type]}")
      end
      if ['asc', 'desc'].include? query[:sort_towards]
        expr = expr.order_by("NULLIF(payments.towards, '') #{query[:sort_towards]}")
      end
    end
    if query[:after_date].present?
      expr = expr.where('payments.date >= timezone(COALESCE(nonprofits.timezone, \'UTC\'), timezone(\'UTC\', $date))', date: query[:after_date])
    end
    if query[:before_date].present?
      expr = expr.where('payments.date <= timezone(COALESCE(nonprofits.timezone, \'UTC\'), timezone(\'UTC\', $date))', date: query[:before_date])
    end
    if query[:amount_greater_than].present?
      expr = expr.where('payments.gross_amount >= $amt', amt: query[:amount_greater_than].to_i * 100)
    end
    if query[:amount_less_than].present?
      expr = expr.where('payments.gross_amount <= $amt', amt: query[:amount_less_than].to_i * 100)
    end
    if query[:year].present?
      expr =
        expr
        .where(
          "to_char(timezone(
            COALESCE(nonprofits.timezone, \'UTC\'),
            timezone(\'UTC\', payments.date)
          ), 'YYYY')=$year",
          year: (query[:year]).to_s
        )
    end
    if query[:designation].present?
      expr = expr.where("donations.designation @@ $s", s: "#{query[:designation]}")
    end
    if query[:dedication].present?
      expr = expr.where("donations.dedication @@ $s", s: "#{query[:dedication]}")
    end
    if query[:donation_type].present?
      expr = expr.where('payments.kind IN ($kinds)', kinds: query[:donation_type].split(','))
    end

    if query[:check_number].present?
      expr = expr
          .join(
              "offsite_payments", 
            "offsite_payments.payment_id = payments.id AND offsite_payments.check_number = $check_number",
            check_number: query[:check_number]
          )
    end

    if query[:campaign_id].present?
      campaign_search = campaign_and_child_query_as_raw_string
      expr = expr
                 .left_outer_join("campaigns", "campaigns.id=donations.campaign_id" )
                 .where("campaigns.id IN (#{campaign_search})", id: query[:campaign_id])
    end
    if query[:event_id].present?
      tickets_subquery = Qexpr.new.select("payment_id", "MAX(event_id) AS event_id").from("tickets").where('tickets.event_id=$event_id', event_id: query[:event_id]).group_by("payment_id").as("tix")
      expr = expr
                 .left_outer_join(tickets_subquery, "tix.payment_id=payments.id")
                 .where("tix.event_id=$id OR donations.event_id=$id", id: query[:event_id])

    end

    if query[:anonymous].present?
      expr = if(query[:anonymous] == 'true')
        expr.where(
          '(supporters.anonymous OR donations.anonymous)'
        )
      else
        expr.where(
          '(NOT supporters.anonymous AND NOT donations.anonymous)'
        )
      end
    end

    if query[:payout_id].present?
      expr = expr.join("payment_payouts", "payment_payouts.payout_id = $payout_id AND payment_payouts.payment_id = payments.id", {payout_id: query[:payout_id].to_i})
    end

    if query.has_key? :supporter_covered_fee

      if query[:supporter_covered_fee]
        expr = expr.join("misc_payment_infos", "misc_payment_infos.payment_id = payments.id")
        expr = expr.where("COALESCE(misc_payment_infos.fee_covered, false)")
      else
        expr = expr.left_outer_join("misc_payment_infos", "misc_payment_infos.payment_id = payments.id")
        expr = expr.where("misc_payment_infos.id IS NULL OR NOT COALESCE(misc_payment_infos.fee_covered, false)")
      end
    end

    if query.has_key? :online_payments_only
      if query[:online_payments_only]
        expr = expr.join(:charges, "charges.payment_id = payments.id AND charges.status != $status", status: 'failed')
      end
    end

    if query[:tag_master_id]
      expr = expr.join(:tag_joins, "tag_joins.tag_master_id = $tag_master_id AND tag_joins.supporter_id = supporters.id", tag_master_id: query[:tag_master_id].to_i)
    end

    #we have the first part of the search. We need to create the second in certain situations
    filtered_payment_id_search = expr.parse

    if query[:event_id].present? || query[:campaign_id].present?
      filtered_payment_id_search = filtered_payment_id_search + " UNION DISTINCT " + create_reverse_select(npo_id, query).parse
    end

    filtered_payment_id_search
  end

  # we use this when we need to get the refund info
  def self.create_reverse_select(npo_id,  query)
    inner_donation_search = Qexpr.new.select('donations.*').from('donations')
    if (query[:event_id].present?)
      inner_donation_search = inner_donation_search.where('donations.event_id=$id', id: query[:event_id])
    end
    if (query[:campaign_id].present?)
      campaign_search = campaign_and_child_query_as_raw_string
      inner_donation_search = inner_donation_search.where("donations.campaign_id IN (#{campaign_search})", id: query[:campaign_id])
    end
    expr = Qexpr.new.select('payments.id').from('payments')
          .inner_join('supporters', "supporters.id=payments.supporter_id")
          .left_outer_join('refunds', 'payments.id=refunds.payment_id')
          .left_outer_join('charges', 'refunds.charge_id=charges.id')
          .left_outer_join('payments AS payments_orig', 'payments_orig.id=charges.payment_id')
          .left_outer_join(inner_donation_search.as('donations'), 'donations.id=payments_orig.donation_id' )
          .where('payments.nonprofit_id=$id', id: npo_id.to_i)


    if query[:search].present?
      expr = SearchVector.query(query[:search], expr)
    end
    
    if query[:after_date].present?
      expr = expr.where('payments.date >= $date', date: query[:after_date])
    end
    if query[:before_date].present?
      expr = expr.where('payments.date <= $date', date: query[:before_date])
    end
    if query[:amount_greater_than].present?
      expr = expr.where('payments.gross_amount >= $amt', amt: query[:amount_greater_than].to_i * 100)
    end
    if query[:amount_less_than].present?
      expr = expr.where('payments.gross_amount <= $amt', amt: query[:amount_less_than].to_i * 100)
    end
    if query[:year].present?
      expr = expr.where("to_char(payments.date, 'YYYY')=$year", year: query[:year])
    end
    if query[:designation].present?
      expr = expr.where("donations.designation @@ $s", s: "#{query[:designation]}")
    end
    if query[:dedication].present?
      expr = expr.where("donations.dedication @@ $s", s: "#{query[:dedication]}")
    end
    if query[:donation_type].present?
      expr = expr.where('payments.kind IN ($kinds)', kinds: query[:donation_type].split(','))
    end

    if query[:check_number].present?
      expr = expr
          .join(
              "offsite_payments", 
            "offsite_payments.payment_id = payments.id AND offsite_payments.check_number = $check_number",
            check_number: query[:check_number]
          )
    end

    if query[:campaign_id].present?
      campaign_search = campaign_and_child_query_as_raw_string
      expr = expr
                 .left_outer_join("campaigns", "campaigns.id=donations.campaign_id" )
                 .where("campaigns.id IN (#{campaign_search})", id: query[:campaign_id])
    end
    if query[:event_id].present?
      tickets_subquery = Qexpr.new.select("payment_id", "MAX(event_id) AS event_id").from("tickets").where('tickets.event_id=$event_id', event_id: query[:event_id]).group_by("payment_id").as("tix")
      expr = expr
                 .left_outer_join(tickets_subquery, "tix.payment_id=payments_orig.id")
                 .where("tix.event_id=$id OR donations.event_id=$id", id: query[:event_id])

    end

    expr
  end

  # Create the data structure for the payout export CSVs
  # Has two sections: two rows for info about the payout, then all the rows after that are for the payments
  # TODO reuse the standard payment export query for the payment rows for this query
  def self.for_payout(npo_id, payout_id)
    tickets_subquery = Qx.select("payment_id", "MAX(event_id) AS event_id").from("tickets").group_by("payment_id").as("tickets")
    Qx.select(
        "to_char(payouts.created_at, 'MM/DD/YYYY HH24:MIam') AS date",
        "(payouts.gross_amount / 100.0)::money::text AS gross_total",
        "(payouts.fee_total / 100.0)::money::text AS fee_total",
        "(payouts.net_amount / 100.0)::money::text AS net_total",
        "bank_accounts.name AS bank_name",
        "payouts.status"
      )
      .from(:payouts)
      .join(:bank_accounts, "bank_accounts.nonprofit_id=payouts.nonprofit_id")
      .where("payouts.nonprofit_id=$id", id: npo_id)
      .and_where("payouts.id=$id", id: payout_id)
      .execute(format: 'csv')
      .concat([[]])
      .concat(
        Qx.select([
          "to_char(payments.date, 'MM/DD/YYYY HH24:MIam') AS \"Date\"",
          "(payments.gross_amount/100.0)::money::text AS \"Gross Amount\"",
          "(payments.fee_total / 100.0)::money::text AS \"Fee Total\"",
          "(payments.net_amount / 100.0)::money::text AS \"Net Amount\"",
          "payments.kind AS \"Type\"",
          "payments.id AS \"Payment ID\""
         ].concat(QuerySupporters.supporter_export_selections(:anonymous))
          .concat([
            "coalesce(donations.designation, 'None') AS \"Designation\"",
            "donations.dedication AS \"Honorarium/Memorium\"",
            "(donations.anonymous OR supporters.anonymous) AS \"Anonymous?\"",
            "donations.comment AS \"Comment\"",
            "coalesce(nullif(campaigns.name, ''), 'None') AS \"Campaign\"",
            "coalesce(nullif(campaign_gift_options.name, ''), 'None') AS \"Campaign Gift Level\"",
            "coalesce(events.name, 'None') AS \"Event\"",
            "coalesce(misc_payment_infos.fee_covered, 'f') AS \"Fee Covered?\""
          ])
        )
        .distinct_on('payments.date, payments.id')
        .from(:payments)
        .join(:payment_payouts, "payment_payouts.payment_id=payments.id")
        .add_join(:payouts, "payouts.id=payment_payouts.payout_id")
        .left_join(:supporters, "payments.supporter_id=supporters.id")
        .add_left_join(:donations, "donations.id=payments.donation_id")
        .add_left_join(:campaigns, "donations.campaign_id=campaigns.id")
        .add_left_join(:campaign_gifts, "donations.id=campaign_gifts.donation_id")
        .add_left_join(:campaign_gift_options, "campaign_gift_options.id=campaign_gifts.campaign_gift_option_id")
        .add_left_join(tickets_subquery, "tickets.payment_id=payments.id")
        .add_left_join(:events, "events.id=tickets.event_id OR (events.id = donations.event_id)")
        .add_left_join(:misc_payment_infos, "payments.id=misc_payment_infos.payment_id")
        .where("payouts.id=$id", id: payout_id)
        .and_where("payments.nonprofit_id=$id", id: npo_id)
        .order_by("payments.date DESC, payments.id")
        .execute(format: 'csv')
      )
  end

  def self.find_payments_where_too_far_from_charge_date(id=nil)
    pay = Payment.includes(:donation).includes(:offsite_payment)
    if (id)
      pay = pay.where('id = ?', id)
    end
    pay = pay.where('date IS NOT NULL').order('id ASC')
    pay.all.each{|p|
      next if p.offsite_payment != nil
      lowest_charge_for_payment = Charge.where('payment_id = ?', p.id).order('created_at ASC').limit(1).first


      if (lowest_charge_for_payment)
        diff = p.date - lowest_charge_for_payment.created_at
        diff_too_big = diff > 10.minutes || diff < -10.minutes
      end
      if (lowest_charge_for_payment && diff_too_big)
        yield(p.donation.id, p.donation.date, p.id, p.date, lowest_charge_for_payment.id, lowest_charge_for_payment.created_at, diff)
      end

    }
  end

  def self.campaign_and_child_query_as_raw_string
    "SELECT c_temp.id from campaigns c_temp where c_temp.id=$id OR c_temp.parent_campaign_id=$id"
  end

  def self.query_payout_info(npo_id, payout_id)
    tickets_subquery = Qx.select("payment_id", "MAX(event_id) AS event_id").from("tickets").group_by("payment_id").as("tickets")
    Qx.select([
      "to_char(payments.date, 'MM/DD/YYYY HH24:MIam') AS \"Date\"",
      "(payments.gross_amount/100.0)::money::text AS \"Gross Amount\"",
      "(payments.fee_total / 100.0)::money::text AS \"Fee Total\"",
      "(payments.net_amount / 100.0)::money::text AS \"Net Amount\"",
      "payments.kind AS \"Type\"",
      "payments.id AS \"Payment ID\""
     ].concat(QuerySupporters.supporter_export_selections(:anonymous))
      .concat([
        "coalesce(donations.designation, 'None') AS \"Designation\"",
        "donations.dedication AS \"Honorarium/Memorium\"",
        "(donations.anonymous OR supporters.anonymous) AS \"Anonymous?\"",
        "donations.comment AS \"Comment\"",
        "coalesce(nullif(campaigns.name, ''), 'None') AS \"Campaign\"",
        "coalesce(nullif(campaign_gift_options.name, ''), 'None') AS \"Campaign Gift Level\"",
        "coalesce(events.name, 'None') AS \"Event\""
      ])
    )
    .distinct_on('payments.date, payments.id')
    .from(:payments)
    .join(:payment_payouts, "payment_payouts.payment_id=payments.id")
    .add_join(:payouts, "payouts.id=payment_payouts.payout_id")
    .left_join(:supporters, "payments.supporter_id=supporters.id")
    .add_left_join(:donations, "donations.id=payments.donation_id")
    .add_left_join(:campaigns, "donations.campaign_id=campaigns.id")
    .add_left_join(:campaign_gifts, "donations.id=campaign_gifts.donation_id")
    .add_left_join(:campaign_gift_options, "campaign_gift_options.id=campaign_gifts.campaign_gift_option_id")
    .add_left_join(tickets_subquery, "tickets.payment_id=payments.id")
    .add_left_join(:events, "events.id=tickets.event_id OR (events.id = donations.event_id)")
    .where("payouts.id=$id", id: payout_id)
    .and_where("payments.nonprofit_id=$id", id: npo_id)
    .order_by("payments.date DESC, payments.id")
  end

  def self.get_dedication_or_empty(*path)
    "json_extract_path_text(coalesce(nullif(trim(both from donations.dedication), ''), '{}')::json, #{path.map{|i| "'#{i}'"}.join(',')})"
  end
end
