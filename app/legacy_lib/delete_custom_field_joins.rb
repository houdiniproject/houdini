# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module DeleteCustomFieldJoins
  @columns = %w[id custom_field_definition_id supporter_id value created_at updated_at metadata]
  def self.find_multiple_custom_field_joins
    bad_results = Qx.select("CONCAT(custom_field_joins.supporter_id, '_', custom_field_joins.custom_field_definition_id) AS our_concat, COUNT(id) AS our_count")
      .from(:custom_field_joins)
      .group_by("our_concat")
      .having("COUNT(id) > 1").parse

    custom_field_joins_from_qx = CustomFieldJoin
      .where("CONCAT(custom_field_joins.supporter_id, '_', custom_field_joins.custom_field_definition_id) IN (SELECT our_concat FROM (#{bad_results}) AS ignore)")
      .select("id, custom_field_definition_id, supporter_id, created_at, updated_at")
    grouped_custom_field_joins = custom_field_joins_from_qx.group_by { |tj| "#{tj.supporter_id}_#{tj.custom_field_definition_id}" }

    ids_to_delete = []
    grouped_custom_field_joins.each do |_, v|
      sorted = v.sort_by(&:updated_at).to_a
      ids_to_delete += sorted.map(&:id)[0, sorted.count - 1]
    end

    ids_to_delete
  end

  def self.copy_and_delete(ids_to_delete)
    if ids_to_delete.any?
      Qx.insert_into(:custom_field_joins_backup, @columns).select(@columns).from(:custom_field_joins).where("id IN ($ids)", ids: ids_to_delete).execute
      CustomFieldJoin.where("id IN (?)", ids_to_delete).delete_all
    end
  end

  def self.revert
    Qx.insert_into(:custom_field_joins, @columns).select(@columns).from(:custom_field_joins_backup).execute
    Qx.execute_raw("DELETE FROM custom_field_joins_backup")
  end
end
