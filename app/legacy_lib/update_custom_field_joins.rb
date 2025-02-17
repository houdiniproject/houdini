# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

module UpdateCustomFieldJoins
  # Delete custom field joins that have the same custom field master
  # Favor the most recent custom field join
  def self.delete_dupes(supporter_ids)
    # Bulk remove duplicate custom field joins, favoring the most recent one
    ids = Qx.select("ARRAY_AGG(custom_field_joins.id ORDER BY custom_field_joins.created_at DESC) AS ids")
      .from(:custom_field_joins)
      .where("custom_field_joins.supporter_id IN ($ids)", ids: supporter_ids)
      .join("custom_field_definitions cfms", "cfms.id = custom_field_joins.custom_field_definition_id")
      .group_by("cfms.name")
      .having("COUNT(custom_field_joins) > 1")
      .execute.map { |h| h["ids"][1..-1] }.flatten
    return unless ids.any?

    Qx.delete_from(:custom_field_joins)
      .where("id IN ($ids)", ids: ids)
      .execute
  end
end
