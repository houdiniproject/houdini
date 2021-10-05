# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.array!(
	@tag_definitions,
	partial: '/api/tag_definitions/tag_definition',
	as: 'tag_definition'
)
