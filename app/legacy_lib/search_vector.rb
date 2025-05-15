# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

module SearchVector
  AcceptedTables = ["supporters", "payments"]

  def self.query(query_string, expr = nil)
    query = if (query_string.is_a?(Integer) || query_string.is_int?) && SearchVector.within_postgres_integer_limit(query_string)
      "(supporters.fts @@ websearch_to_tsquery('english', $search::varchar(255))
        OR donations.fts  @@ websearch_to_tsquery('english', $search::varchar(255))
        OR (
          supporters.phone IS NOT NULL
          AND supporters.phone != ''
          AND supporters.phone_index = $search::varchar(255)
        )
        OR payments.id = $search::INTEGER)"
    else
      "(supporters.fts @@ websearch_to_tsquery('english', $search)
        OR (
          supporters.phone IS NOT NULL
          AND supporters.phone != ''
          AND supporters.phone_index IS NOT NULL
          AND supporters.phone_index != ''
          AND supporters.phone_index = (regexp_replace($search, '\\D','', 'g'))
        )
        OR donations.fts  @@ websearch_to_tsquery('english', $search))"
    end

    (expr || Qexpr.new).where(query, {search: query_string})
  end

  def self.within_postgres_integer_limit(test_int)
    test_int.to_i > 0 && test_int.to_i <= 2147483647
  end
end
