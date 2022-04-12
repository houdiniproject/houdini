# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'psql'
require 'qexpr'

module QueryCustomFields


  # Find all duplicate custom field joins on supporters
  # Returns an array of groups of duplicate custom_field_join_ids
  def self.find_dupes(np_id)
    Qx.select("ARRAY_AGG(custom_field_joins.id)")
      .from(:custom_field_joins)
      .join(:custom_field_masters, "custom_field_masters.id=custom_field_joins.custom_field_master_id")
      .where("custom_field_masters.nonprofit_id=$id", id: np_id)
      .group_by("custom_field_joins.custom_field_master_id", "custom_field_joins.value", "custom_field_joins.supporter_id")
      .having("COUNT(custom_field_joins.id) > 1")
      .execute(format: 'csv')[1..-1]
  end

end
