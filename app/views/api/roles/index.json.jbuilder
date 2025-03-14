# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.data @roles, partial: "/api/roles/role", as: :role

json.current_page @roles.current_page
json.first_page @roles.first_page?
json.last_page @roles.last_page?
json.requested_size @roles.limit_value
json.total_count @roles.total_count
