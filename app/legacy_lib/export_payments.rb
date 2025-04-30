# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

module ExportPayments
  def self.initiate_export(npo_id, params, user_id)
    ParamValidation.new({npo_id: npo_id, params: params, user_id: user_id},
      npo_id: {required: true, is_integer: true},
      params: {required: true, is_hash: true},
      user_id: {required: true, is_integer: true})
    npo = Nonprofit.where("id = ?", npo_id).first
    unless npo
      raise ParamValidation::ValidationError.new("Nonprofit #{npo_id} doesn't exist!", key: :npo_id)
    end
    user = User.where("id = ?", user_id).first
    unless user
      raise ParamValidation::ValidationError.new("User #{user_id} doesn't exist!", key: :user_id)
    end

    e = Export.create(nonprofit: npo, user: user, status: :queued, export_type: "ExportPayments", parameters: params.to_json)

    DelayedJobHelper.enqueue_job(ExportPayments, :run_export, [npo_id, params.to_json, user_id, e.id])
  end

  def self.run_export(npo_id, params, user_id, export_id)
    # need to check that
    ParamValidation.new({npo_id: npo_id, params: params, user_id: user_id, export_id: export_id},
      npo_id: {required: true, is_integer: true},
      params: {required: true, is_json: true},
      user_id: {required: true, is_integer: true},
      export_id: {required: true, is_integer: true})

    params = JSON.parse(params, object_class: HashWithIndifferentAccess)
    # verify that it's also a hash since we can't do that at once
    ParamValidation.new({params: params},
      params: {is_hash: true})
    begin
      export = Export.find(export_id)
    rescue ActiveRecord::RecordNotFound
      raise ParamValidation::ValidationError.new("Export #{export_id} doesn't exist!", key: :export_id)
    end
    export.status = :started
    export.save!

    unless Nonprofit.exists?(npo_id)
      raise ParamValidation::ValidationError.new("Nonprofit #{npo_id} doesn't exist!", key: :npo_id)
    end
    user = User.where("id = ?", user_id).first
    unless user
      raise ParamValidation::ValidationError.new("User #{user_id} doesn't exist!", key: :user_id)
    end

    file_date = Time.now.getutc.strftime("%m-%d-%Y--%H-%M-%S")
    filename = "tmp/csv-exports/payments-#{export.id}-#{file_date}.csv"

    url = CHUNKED_UPLOADER.upload(filename, for_export_enumerable(npo_id, params, 15000).map { |i| i.to_csv }, content_type: "text/csv", content_disposition: "attachment")
    export.url = url
    export.status = :completed
    export.ended = Time.now
    export.save!

    ExportMailer.delay.export_payments_completed_notification(export)
  rescue => e
    if export
      export.status = :failed
      export.exception = e.to_s
      export.ended = Time.now
      export.save!

      begin
        user ||= User.where("id = ?", user_id).first
        if user
          ExportMailer.delay.export_payments_failed_notification(export)
        end
      rescue
      end
      raise e
    end
    raise e
  end

  private

  def self.for_export_enumerable(npo_id, query, chunk_limit = 15000)
    ParamValidation.new({npo_id: npo_id, query: query}, {npo_id: {required: true, is_int: true},
                                                        query: {required: true, is_hash: true}})

    QexprQueryChunker.for_export_enumerable(chunk_limit) do |offset, limit, skip_header|
      get_chunk_of_export(npo_id, query, offset, limit, skip_header)
    end
  end

  def self.get_chunk_of_export(npo_id, query, offset = nil, limit = nil, skip_header = false)
    QexprQueryChunker.get_chunk_of_query(offset, limit, skip_header) do
      QueryPayments.full_search_expr(npo_id, query)
        .select(*export_selects(query[:export_format_id]))
        .left_outer_join("campaign_gifts", "campaign_gifts.donation_id=donations.id")
        .left_outer_join("campaign_gift_options", "campaign_gifts.campaign_gift_option_id=campaign_gift_options.id")
        .left_outer_join("(#{campaigns_with_creator_email}) AS campaigns_for_export", "donations.campaign_id=campaigns_for_export.id")
        .left_outer_join(tickets, "tickets.payment_id=payments.id")
        .left_outer_join("events events_for_export", "events_for_export.id=tickets.event_id OR donations.event_id=events_for_export.id")
        .left_outer_join("offsite_payments", "offsite_payments.payment_id=payments.id")
        .left_outer_join("misc_payment_infos", "payments.id = misc_payment_infos.payment_id")
    end
  end

  def self.export_selects(export_format_id)
    if export_format_id.present?
      return build_export_select_using_export_format(ExportFormat.find(export_format_id))
    end
    ["to_char(payments.date::timestamptz at time zone COALESCE(nonprofits.timezone, 'UTC'), 'YYYY-MM-DD HH24:MI:SS TZ') AS date",
      "(payments.gross_amount / 100.0)::money::text AS gross_amount",
      "(payments.fee_total / 100.0)::money::text AS fee_total",
      "(payments.net_amount / 100.0)::money::text AS net_amount",
      "payments.kind AS type"]
      .concat(QuerySupporters.supporter_export_selections(:anonymous))
      .concat([
        "coalesce(donations.designation, 'None') AS designation",
        "#{QueryPayments.get_dedication_or_empty("type")}::text AS \"Dedication Type\"",
        "#{QueryPayments.get_dedication_or_empty("name")}::text AS \"Dedicated To: Name\"",
        "#{QueryPayments.get_dedication_or_empty("supporter_id")}::text AS \"Dedicated To: Supporter ID\"",
        "#{QueryPayments.get_dedication_or_empty("contact", "email")}::text AS \"Dedicated To: Email\"",
        "#{QueryPayments.get_dedication_or_empty("contact", "phone")}::text AS \"Dedicated To: Phone\"",
        "#{QueryPayments.get_dedication_or_empty("contact", "address")}::text AS \"Dedicated To: Address\"",
        "#{QueryPayments.get_dedication_or_empty("note")}::text AS \"Dedicated To: Note\"",
        '(donations.anonymous OR supporters.anonymous) AS "Anonymous?"',
        "donations.comment",
        "coalesce(nullif(campaigns_for_export.name, ''), 'None') AS campaign",
        "campaigns_for_export.id AS \"Campaign Id\"",
        "coalesce(nullif(campaigns_for_export.creator_email, ''), '') AS campaign_creator_email",
        "coalesce(nullif(campaign_gift_options.name, ''), 'None') AS campaign_gift_level",
        "events_for_export.name AS event_name",
        "payments.id AS payment_id",
        "offsite_payments.check_number AS check_number",
        "donations.comment AS donation_note",
        "CASE WHEN payments.kind = 'RecurringDonation'
        THEN to_char(donations.created_at::timestamptz at time zone COALESCE(nonprofits.timezone, 'UTC'), 'YYYY-MM-DD HH24:MI:SS TZ')
        ELSE '' END AS \"Recurring Donation Started At\"",
        'coalesce(nullif(misc_payment_infos.fee_covered, false), false) AS "Fee Covered by Supporter"'
      ])
  end

  def self.build_export_select_using_export_format(export_format)
    build_payments_select(export_format)
      .concat(QuerySupporters.supporter_export_selections(:anonymous))
      .concat(build_donations_and_campaigns_select(export_format))
  end

  def self.build_payments_select(export_format)
    custom_names = build_custom_names_for_payments(export_format.custom_columns_and_values)
    date_format = export_format.date_format || "YYYY-MM-DD HH24:MI:SS TZ"
    payments_select = ["to_char(payments.date::timestamptz at time zone COALESCE(nonprofits.timezone, 'UTC'), '#{date_format}') AS #{custom_names["payments.date"]}"]

    if export_format.show_currency
      payments_select.concat([
        "#{money_with_currency("payments.gross_amount")} AS #{custom_names["payments.gross_amount"]}",
        "#{money_with_currency("payments.fee_total")} AS #{custom_names["payments.fee_total"]}",
        "#{money_with_currency("payments.net_amount")} AS #{custom_names["payments.net_amount"]}"
      ])
    else
      payments_select.concat([
        "#{money_without_currency("payments.gross_amount")} AS #{custom_names["payments.gross_amount"]}",
        "#{money_without_currency("payments.fee_total")} AS #{custom_names["payments.fee_total"]}",
        "#{money_without_currency("payments.net_amount")} AS #{custom_names["payments.net_amount"]}"
      ])
    end
    payments_select.concat([build_custom_value_clause("payments.kind", export_format.custom_columns_and_values, custom_names["payments.kind"])])
  end

  def self.build_donations_and_campaigns_select(export_format)
    custom_columns_and_values = export_format.custom_columns_and_values
    custom_names = build_custom_names_for_donations_and_campaigns(custom_columns_and_values)
    date_format = export_format.date_format || "YYYY-MM-DD HH24:MI:SS TZ"
    [
      build_custom_value_clause("donations.designation", custom_columns_and_values, custom_names["donations.designation"], "coalesce(donations.designation, 'None')"),
      "#{QueryPayments.get_dedication_or_empty("type")}::text AS \"Dedication Type\"",
      "#{QueryPayments.get_dedication_or_empty("name")}::text AS \"Dedicated To: Name\"",
      "#{QueryPayments.get_dedication_or_empty("supporter_id")}::text AS \"Dedicated To: Supporter ID\"",
      "#{QueryPayments.get_dedication_or_empty("contact", "email")}::text AS \"Dedicated To: Email\"",
      "#{QueryPayments.get_dedication_or_empty("contact", "phone")}::text AS \"Dedicated To: Phone\"",
      "#{QueryPayments.get_dedication_or_empty("contact", "address")}::text AS \"Dedicated To: Address\"",
      "#{QueryPayments.get_dedication_or_empty("note")}::text AS \"Dedicated To: Note\"",
      build_custom_value_clause("donations.anonymous OR supporters.anonymous", custom_columns_and_values, custom_names["donations.anonymous OR supporters.anonymous"], "(donations.anonymous OR supporters.anonymous)"),
      build_custom_value_clause("donations.comment", custom_columns_and_values, '"Comment"'),
      build_custom_value_clause("campaigns_for_export.name", custom_columns_and_values, custom_names["campaigns_for_export.name"], "coalesce(nullif(campaigns_for_export.name, ''), 'None')"),
      "campaigns_for_export.id AS #{custom_names["campaigns_for_export.id"]}",
      "coalesce(nullif(campaigns_for_export.creator_email, ''), '') AS #{custom_names["campaigns_for_export.creator_email"]}",
      build_custom_value_clause("campaign_gift_options.name", custom_columns_and_values, custom_names["campaign_gift_options.name"], "coalesce(nullif(campaign_gift_options.name, ''), 'None')"),
      build_custom_value_clause("campaigns_for_export.name", custom_columns_and_values, custom_names["campaigns_for_export.name"], "coalesce(nullif(campaign_gift_options.name, ''), 'None')"),
      build_custom_value_clause("events_for_export.name", custom_columns_and_values, custom_names["events_for_export.name"]),
      "payments.id AS #{custom_names["payments.id"]}",
      "offsite_payments.check_number AS #{custom_names["offsite_payments.check_number"]}",
      build_custom_value_clause("donations.comment", custom_columns_and_values, custom_names["donations.comment"]),
      "CASE WHEN payments.kind = 'RecurringDonation'
        THEN to_char(donations.created_at::timestamptz at time zone COALESCE(nonprofits.timezone, 'UTC'), '#{date_format}')
        ELSE '' END AS #{custom_names["donations.created_at"]}",
      build_custom_value_clause("misc_payment_infos.fee_covered", custom_columns_and_values, custom_names["misc_payment_infos.fee_covered"], "coalesce(nullif(misc_payment_infos.fee_covered, false), false)")
    ]
  end

  def self.build_custom_value_clause(column_name, custom_columns_and_values, custom_column_name, column_treatment = column_name)
    custom_values = custom_columns_and_values&.dig(column_name)&.dig("custom_values")
    if custom_values.present?
      return build_custom_values_switch_case(custom_values, column_treatment, custom_column_name)
    end
    "#{column_treatment} AS #{custom_column_name}"
  end

  def self.build_custom_values_switch_case(custom_values, column_name, custom_column_name)
    statement = "CASE "
    custom_values.each do |original_value, new_value|
      statement << "WHEN #{column_name} = '#{original_value}' THEN '#{new_value}' "
    end
    statement << "ELSE #{column_name} END AS #{custom_column_name}"
  end

  def self.build_custom_names_for_payments(custom_names)
    {
      "payments.date" => custom_names&.dig("payments.date")&.dig("custom_name") || "date",
      "payments.gross_amount" => custom_names&.dig("payments.gross_amount")&.dig("custom_name") || "gross_amount",
      "payments.fee_total" => custom_names&.dig("payments.fee_total")&.dig("custom_name") || "fee_total",
      "payments.net_amount" => custom_names&.dig("payments.net_amount")&.dig("custom_name") || "net_amount",
      "payments.kind" => custom_names&.dig("payments.kind")&.dig("custom_name") || "type"
    }
  end

  def self.build_custom_names_for_donations_and_campaigns(custom_names)
    {
      "donations.designation" => custom_names&.dig("donations.designation")&.dig("custom_name") || "designation",
      "donations.anonymous OR supporters.anonymous" => (
        custom_names&.dig("donations.anonymous OR supporters.anonymous") ||
        custom_names&.dig("donations.anonymous") ||
        custom_names&.dig("supporters.anonymous")
      )&.dig("custom_name") || '"Anonymous?"',
      "campaigns_for_export.name" => custom_names&.dig("campaigns_for_export.name")&.dig("custom_name") || "campaign",
      "campaigns_for_export.id" => custom_names&.dig("campaigns_for_export.id")&.dig("custom_name") || '"Campaign Id"',
      "campaigns_for_export.creator_email" => custom_names&.dig("campaigns_for_export.creator_email")&.dig("custom_name") || "campaign_creator_email",
      "campaign_gift_options.name" => custom_names&.dig("campaign_gift_options.name")&.dig("custom_name") || "campaign_gift_level",
      "events_for_export.name" => custom_names&.dig("events_for_export.name")&.dig("custom_name") || "event_name",
      "payments.id" => custom_names&.dig("payments.id")&.dig("custom_name") || "payment_id",
      "offsite_payments.check_number" => custom_names&.dig("offsite_payments.check_number")&.dig("custom_name") || "check_number",
      "donations.comment" => custom_names&.dig("donations.comment")&.dig("custom_name") || "donation_note",
      "donations.created_at" => custom_names&.dig("donations.created_at")&.dig("custom_name") || '"Recurring Donation Started At"',
      "misc_payment_infos.fee_covered" => custom_names&.dig("misc_payment_infos.fee_covered")&.dig("custom_name") || '"Fee Covered by Supporter"'
    }
  end

  def self.money_with_currency(column)
    "(#{column} / 100.0)::money::text"
  end

  def self.money_without_currency(column)
    "ROUND((#{column} / 100.0), 2)::text"
  end

  def self.campaigns_with_creator_email
    Qexpr
      .new
      .select("campaigns.*, users.email AS creator_email")
      .from(:campaigns)
      .left_outer_join(:profiles, "profiles.id = campaigns.profile_id")
      .left_outer_join(:users, "users.id = profiles.user_id")
  end

  def self.tickets
    Qexpr
      .new
      .select("payment_id", "MAX(event_id) AS event_id")
      .from("tickets")
      .group_by("payment_id")
      .as("tickets")
  end
end
