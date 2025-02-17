# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

module SearchVector
  AcceptedTables = %w[supporters payments].freeze

  def self.query(query_string, expr = nil)
    (expr || Qexpr.new).where(
      "to_tsvector('english', coalesce(supporters.name, '') || ' ' || coalesce(supporters.email, '')) @@ plainto_tsquery('english', $search)",
      search: query_string
    )
  end

  def self._payments_blob_query
    Qexpr.new.select(
      "payments.id",
      "concat_ws(' '
        , payments.gross_amount
        , payments.kind
        , payments.towards
        , supporters.name
        , supporters.organization
        , supporters.email
        , supporters.city
        , supporters.state_code
        , donations.designation
        , donations.dedication
        ) AS search_blob"
    )
      .from(:payments)
      .left_outer_join("supporters", "payments.supporter_id=supporters.id")
      .left_outer_join("donations", "payments.donation_id=donations.id")
  end

  # Construct of query of ids and search blobs for all supporters
  # for use in a sub-query
  def self._supporters_blob_query
    fields_subquery = Qexpr.new.select("string_agg(value::text, ' ') AS value", "supporter_id")
      .from(:custom_field_joins)
      .group_by(:supporter_id)
      .as(:custom_field_joins)
    Qexpr.new.select(
      "supporters.id",
      "concat_ws(' '
        , custom_field_joins.value
        , supporters.name
        , supporters.organization
        , supporters.id
        , supporters.email
        , supporters.city
        , supporters.state_code
        , donations.designation
        , donations.dedication
        , payments.kind
        , payments.towards
        ) AS search_blob"
    )
      .from(:supporters)
      .left_outer_join(:payments, "payments.supporter_id=supporters.id")
      .left_outer_join(:donations, "donations.supporter_id=supporters.id")
      .left_outer_join(fields_subquery, "custom_field_joins.supporter_id=supporters.id")
  end
end
