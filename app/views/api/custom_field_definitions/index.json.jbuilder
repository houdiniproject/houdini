# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.array!(
	@custom_field_definitions,
	partial: '/api/custom_field_definitions/custom_field_definition',
	as: 'custom_field_definition'
)
