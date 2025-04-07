# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

module QueryCustomFields
  # Find all duplicate custom field joins on supporters
  # Returns an array of groups of duplicate custom_field_join_ids
  def self.find_dupes(np_id)
    Qx.select("ARRAY_AGG(custom_field_joins.id)")
      .from(:custom_field_joins)
      .join(:custom_field_definitions, "custom_field_definitions.id=custom_field_joins.custom_field_definition_id")
      .where("custom_field_definitions.nonprofit_id=$id", id: np_id)
      .group_by("custom_field_joins.custom_field_definition_id", "custom_field_joins.value", "custom_field_joins.supporter_id")
      .having("COUNT(custom_field_joins.id) > 1")
      .execute(format: "csv")[1..-1]
  end
end
