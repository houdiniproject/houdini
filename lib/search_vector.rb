# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

module SearchVector

  AcceptedTables = ['supporters', 'payments']

  def self.query(query_string, expr=nil)
    query = if query_string.is_a?(Integer) || query_string.is_int?
      "(supporters.fts @@ websearch_to_tsquery('english', $search::varchar(255))
        OR donations.fts  @@ websearch_to_tsquery('english', $search::varchar(255))
        OR payments.id = $search::INTEGER)"
    else
      "(supporters.fts @@ websearch_to_tsquery('english', $search)
        OR donations.fts  @@ websearch_to_tsquery('english', $search))"
    end

    (expr || Qexpr.new).where(query, { search: query_string })
  end
end
