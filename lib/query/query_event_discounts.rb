module QueryEventDiscounts

  def self.with_event_ids(event_ids)
    return [] if event_ids.empty?
    x = Psql.execute(
      Qexpr.new.select("name", "id", "percent", "code", "created_at")
      .from("event_discounts")
      .where("event_discounts.event_id IN ($ids)", ids: event_ids)
      .order_by("created_at DESC"), 
    ).map{|h| HashWithIndifferentAccess.new(h)}

   end
  
end
