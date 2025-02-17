# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.data(
  @custom_field_definitions,
  partial: "/api/custom_field_definitions/custom_field_definition",
  as: "custom_field_definition"
)

json.current_page @custom_field_definitions.current_page
json.first_page @custom_field_definitions.first_page?
json.last_page @custom_field_definitions.last_page?
json.requested_size @custom_field_definitions.limit_value
json.total_count @custom_field_definitions.total_count
