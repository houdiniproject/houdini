# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.data(
  @ticket_levels,
  partial: "/api/ticket_levels/ticket_level",
  as: "ticket_level"
)

json.current_page @ticket_levels.current_page
json.first_page @ticket_levels.first_page?
json.last_page @ticket_levels.last_page?
json.requested_size @ticket_levels.limit_value
json.total_count @ticket_levels.total_count
