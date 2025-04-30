# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module QueryEventDiscounts
  def self.with_event_ids(event_ids)
    return [] if event_ids.empty?
    Psql.execute(
      Qexpr.new.select("name", "id", "percent", "code", "created_at")
      .from("event_discounts")
      .where("event_discounts.event_id IN ($ids)", ids: event_ids)
      .order_by("created_at DESC")
    ).map { |h| HashWithIndifferentAccess.new(h) }
  end
end
