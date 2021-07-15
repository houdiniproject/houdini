# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

module SearchVector

  AcceptedTables = ['supporters', 'payments']

  def self.query(query_string, expr=nil)
    (expr || Qexpr.new).where(
      "(supporters.fts @@ websearch_to_tsquery('english', $search)
      OR donations.fts  @@ websearch_to_tsquery('english', $search))",
      { search: query_string }
    )
  end
end
