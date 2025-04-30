# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

module NonprofitMetrics
  def self.payments(np_id)
    Qx.select(
      "(SUM(payments.gross_amount) / 100.0)::money::text AS total",
      "(AVG(payments.gross_amount) / 100.0)::money::text AS average",
      "(SUM(week.gross_amount) / 100.0)::money::text AS week",
      "(SUM(month.gross_amount) / 100.0)::money::text AS month",
      "(SUM(year.gross_amount) / 100.0)::money::text AS year"
    )
      .from(:payments)
      .left_join(
        ["payments week", "week.id=payments.id AND week.date > date_trunc('week', NOW())"],
        ["payments month", "month.id=payments.id AND month.date > date_trunc('month', NOW())"],
        ["payments year", "year.id=payments.id AND year.date > date_trunc('year', NOW())"]
      )
      .where("payments.nonprofit_id=$id", id: np_id)
      .execute.last
  end

  def self.recurring(np_id)
    # total, average, this month
    Qx.select(
      "(SUM(recurring_donations.amount) / 100.0)::money::text AS total",
      "(AVG(recurring_donations.amount) / 100.0)::money::text AS average",
      "(SUM(month.amount) / 100.0)::money::text AS month"
    )
      .from(:recurring_donations)
      .left_join("recurring_donations month", "month.id=recurring_donations.id AND month.created_at > date_trunc('month', NOW())")
      .where("recurring_donations.active=TRUE")
      .and_where("recurring_donations.n_failures < 3")
      .and_where("recurring_donations.nonprofit_id=$id", id: np_id)
      .execute.last
  end

  def self.supporters(np_id)
    Qx.select(
      "COUNT(supporters) AS total",
      "COUNT(week) AS week",
      "COUNT(month) AS month"
    )
      .from(:supporters)
      .left_join("supporters week", "week.id=supporters.id AND week.created_at > date_trunc('week', NOW()) AND week.imported_at IS NULL")
      .add_left_join("supporters month", "month.id=supporters.id AND month.created_at > date_trunc('month', NOW()) AND month.imported_at IS NULL")
      .where("coalesce(supporters.deleted, FALSE) = FALSE")
      .and_where("supporters.nonprofit_id=$id", id: np_id)
      .execute.last
  end

  def self.recent_donations(np_id)
    Qx.select(
      "(payments.gross_amount / 100)::money::text AS amount",
      "payments.date",
      "payments.id AS payment_id",
      "supporters.name AS supporter_name",
      "supporters.email AS supporter_email",
      "'/nonprofits/#{np_id}/payments?pid=' || payments.id AS payment_url"
    )
      .from(:payments)
      .join("supporters", "payments.supporter_id=supporters.id")
      .where("payments.nonprofit_id=$id", id: np_id)
      .and_where("payments.kind IN ('Donation', 'RecurringDonation', 'Ticket')")
      .limit(10)
      .order_by("payments.date DESC")
      .execute
  end

  def self.recent_supporters(np_id)
    Qx.select("name", "email", "id", "created_at")
      .from(:supporters)
      .where("supporters.nonprofit_id=$id", id: np_id)
      .and_where("coalesce(supporters.deleted, FALSE) = FALSE")
      .and_where("supporters.import_id IS NULL")
      .limit(10)
      .order_by("supporters.created_at DESC")
      .execute
  end

  def self.all_metrics(np_id)
    keys = [:payments, :recurring, :supporters, :recent_donations, :recent_supporters, :published_campaigns]
    keys.each_with_object({}) do |elem, accum|
      accum[elem] = NonprofitMetrics.send(elem, np_id)
    end
  end

  def self.published_campaigns(np_id)
    Qx.select(
      "campaigns.name",
      "campaigns.id",
      "campaigns.created_at",
      "campaigns.end_datetime",
      "COUNT(supporters.id) AS supporter_count",
      "(SUM(one_time.amount)/ 100)::money::text AS total_one_time",
      "(SUM(recurring_donations.amount)/ 100)::money::text AS total_recurring"
    )
      .from(:campaigns)
      .left_join("donations", "donations.campaign_id=campaigns.id")
      .add_left_join("donations AS one_time", "donations.id=one_time.id AND one_time.recurring_donation_id IS NULL")
      .add_left_join("recurring_donations", "recurring_donations.donation_id=donations.id AND recurring_donations.active=TRUE")
      .add_left_join("supporters", "supporters.id=donations.supporter_id")
      .group_by("campaigns.id")
      .where("campaigns.nonprofit_id=$id", id: np_id)
      .and_where("campaigns.published = TRUE")
      .order_by("campaigns.end_datetime DESC")
      .execute
  end

  # Given a starting date, ending date, and time interval,
  # generate a hash for every date between start and end by the interval
  # each hash has the format {'time_span' => date}
  # each hash is nested in an outer hash,  set to a key that is also the date, lol
  # this is used in the payment_history query to fill in missing dates in the data.
  def self.payment_history_timespans(params)
    raise ArgumentError.new("Invalid timespan") unless ["year", "month", "week", "day"].include? params[:timeSpan]
    date_hash = {}
    beginning_of = "beginning_of_" + params[:timeSpan]

    current_date = Chronic.parse(params[:startDate]).send(beginning_of)
    end_date = Chronic.parse(params[:endDate]).send(beginning_of)
    while current_date <= end_date
      date = current_date.strftime("%F")
      date_hash[date] = {"time_span" => date}
      current_date += 1.send(params[:timeSpan])
    end
    date_hash
  end

  def self.payment_history(params)
    results = Qx.select(
      "to_char(date_trunc('#{params[:timeSpan]}', MAX(payments.date)), 'YYYY-MM-DD') AS time_span",
      "coalesce(SUM(payments.gross_amount), 0) AS total_cents",
      "coalesce(SUM(onetime.gross_amount ), 0) AS onetime_cents",
      "coalesce(SUM(recurring.gross_amount ), 0) AS recurring_cents",
      "coalesce(SUM(tickets.gross_amount ), 0) AS tickets_cents"
    )
      .from(:payments)
      .left_join(
        ["payments AS onetime", "onetime.id=payments.id AND onetime.kind='Donation'"],
        ["payments AS recurring", "recurring.id=payments.id AND recurring.kind='RecurringDonation'"],
        ["payments AS tickets", "tickets.id=payments.id AND tickets.kind='Ticket'"]
      )
      .where("payments.nonprofit_id" => params[:id])
      .and_where("payments.date >= $d", d: params[:startDate])
      .and_where("payments.date <= $d", d: params[:endDate])
      .group_by("date_trunc('#{params[:timeSpan]}', payments.date)")
      .order_by("MAX(payments.date)")
      .execute

    date_hash = payment_history_timespans(params)

    results.each_with_object(date_hash) { |r, acc|
      acc[r["time_span"]] = r
    }.values
  end
end
