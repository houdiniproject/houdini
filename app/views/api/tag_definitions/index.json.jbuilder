# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
json.data @tag_definitions,
										partial: '/api/tag_definitions/tag_definition',
										as: 'tag_definition'

json.current_page @tag_definitions.current_page
json.first_page @tag_definitions.first_page?
json.last_page @tag_definitions.last_page?
json.requested_size @tag_definitions.limit_value
json.total_count @tag_definitions.total_count
