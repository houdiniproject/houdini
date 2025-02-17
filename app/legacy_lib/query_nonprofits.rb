# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

module QueryNonprofits
  def self.all_that_need_payouts
    Psql.execute_vectors(
      Qexpr.new.select(
        "nonprofits.id",
        "nonprofits.stripe_account_id",
        "'support@commitchange.com' AS email",
        "'192.168.0.1' AS user_ip",
        "bank_accounts.name"
      ).from(:nonprofits)
      .where("nonprofits.verification_status='verified'")
      .join(:bank_accounts, "bank_accounts.nonprofit_id=nonprofits.id")
      .where("bank_accounts.pending_verification='f'")
      .join(
        Qexpr.new.select("nonprofit_id")
        .from(:charges).group_by("nonprofit_id")
        .where("status='available'").as("charges"),
        "charges.nonprofit_id=nonprofits.id"
      )
    )[1..-1]
  end

  def self.by_search_string(string)
    results = Psql.execute_vectors(
      Qexpr.new.select(
        "nonprofits.id",
        "nonprofits.name"
      ).from(:nonprofits)
      .where("lower(nonprofits.name) LIKE lower($search)", search: "%#{string}%")
      .where("nonprofits.published='t'")
      .order_by("nonprofits.name ASC")
      .limit(10)
    )[1..-1]
    results = results.map { |id, name| {id: id, name: name} } if results
    results
  end

  def self.for_admin(params)
    expr = Qx.select(
      "nonprofits.id",
      "nonprofits.name",
      "nonprofits.email",
      "nonprofits.state_code",
      "nonprofits.created_at::date::text AS created_at",
      "nonprofits.verification_status",
      "nonprofits.vetted",
      "nonprofits.stripe_account_id",
      "coalesce(events.count, 0) AS events_count",
      "coalesce(campaigns.count, 0) AS campaigns_count",
      "billing_plans.percentage_fee",
      "charges.total_processed",
      "charges.total_fees"
    ).from(:nonprofits)
      .add_left_join(:billing_subscriptions, "billing_subscriptions.nonprofit_id=nonprofits.id")
      .add_left_join(:billing_plans, "billing_subscriptions.billing_plan_id=billing_plans.id")
      .add_left_join(
        Qx.select(
          "((SUM(coalesce(fee, 0)) * .978) / 100)::money::text AS total_fees",
          "(SUM(coalesce(amount, 0)) / 100)::money::text AS total_processed",
          "nonprofit_id"
        )
          .from(:charges)
          .where("status != 'failed'")
          .and_where("created_at::date >= '2017-03-15'")
          .group_by("nonprofit_id")
          .as("charges"),
        "charges.nonprofit_id=nonprofits.id"
      )
      .add_left_join(
        Qx.select("COUNT(id)", "nonprofit_id")
          .from(:events)
          .group_by("nonprofit_id")
          .as("events"),
        "events.nonprofit_id=nonprofits.id"
      )
      .add_left_join(
        Qx.select("COUNT(id)", "nonprofit_id")
          .from(:campaigns)
          .group_by("nonprofit_id")
          .as("campaigns"),
        "campaigns.nonprofit_id=nonprofits.id"
      )
      .paginate(params[:page].to_i, params[:page_length].to_i)
      .order_by("nonprofits.created_at DESC")

    if params[:search].present?
      expr = expr.where(%(
        nonprofits.name ILIKE $search
        OR nonprofits.email ILIKE $search
        OR nonprofits.city ILIKE $search
      ), search: "%" + params[:search] + "%")
    end

    expr.execute
  end

  def self.find_nonprofits_with_no_payments
    Nonprofit.includes(:payments).where("payments.nonprofit_id IS NULL")
  end

  def self.find_nonprofits_with_payments_in_last_n_days(days)
    Payment.where("date >= ?", Time.now - days.days).pluck("nonprofit_id").to_a.uniq
  end

  def self.find_nonprofits_with_payments_but_not_in_last_n_days(days)
    recent_nonprofits = find_nonprofits_with_payments_in_last_n_days(days)
    Payment.where("date < ?", Time.now - days.days).pluck("nonprofit_id").to_a.uniq.reject { |i| recent_nonprofits.include?(i) }
  end
end
