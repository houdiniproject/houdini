# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.data @supporter_addresses, partial: "/api/supporter_addresses/supporter_address", as: "supporter_address"

json.current_page @supporter_addresses.current_page
json.first_page @supporter_addresses.first_page?
json.last_page @supporter_addresses.last_page?
json.requested_size @supporter_addresses.limit_value
json.total_count @supporter_addresses.total_count
