# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

module QueryNonprofits
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
    if results
      results = results.map { |id, name| {id: id, name: name} }
    end
    results
  end

  def self.for_admin(params)
    expr = Qx.select(
      "nonprofits.id",
      "nonprofits.name",
      "nonprofits.email",
      "nonprofits.state_code",
      "nonprofits.created_at::date::text AS created_at",
      "nonprofits.vetted",
      "nonprofits.houid",
      "nonprofits.stripe_account_id",
      "coalesce(events.count, 0) AS events_count",
      "coalesce(campaigns.count, 0) AS campaigns_count",
      "billing_plans.percentage_fee",
      "cards.stripe_customer_id",
      "charges.total_processed",
      "charges.total_fees"
    ).from(:nonprofits)
      .add_left_join(:stripe_accounts, "nonprofits.stripe_account_id=stripe_accounts.stripe_account_id")
      .add_left_join(:cards, "cards.holder_id=nonprofits.id AND cards.holder_type='Nonprofit'")
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
        OR nonprofits.id = $id
      ), search: "%" + params[:search] + "%", id: params[:search].to_i)
    end

    results = expr.execute
    results.map do |i|
      np = Nonprofit.includes(:stripe_account).find(i["id"])
      i["verification_status"] = if np.stripe_account
        np.stripe_account.verification_status
      else
        :unverified
      end
      i
    end
  end
end
