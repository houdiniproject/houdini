# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module UpdateSupporter
  def self.from_info(supporter, params)
    supporter.update_attributes(params)
    # GeocodeModel.delay.geocode(supporter)
    supporter
  end

  # Bulk delete, meaning mark all supporters given by a query as deleted='t'
  def self.bulk_delete(np_id, supporter_ids)
    Qx.update(:supporters)
      .set(deleted: true)
      .where("id IN ($ids)", ids: supporter_ids)
      .and_where("nonprofit_id=$id", id: np_id)
      .returning("id")
      .execute
  end

  def self.general_info(supporter_id, data)
    Qx.update(:supporters).set(data).where(id: supporter_id).returning("*").ex.last
  end
end
