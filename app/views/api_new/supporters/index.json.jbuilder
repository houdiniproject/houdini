# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.data @supporters, partial: "/api_new/supporters/supporter", as: :supporter

json.current_page @supporters.current_page
json.first_page @supporters.first_page?
json.last_page @supporters.last_page?
json.requested_size @supporters.limit_value
json.total_count @supporters.total_count
