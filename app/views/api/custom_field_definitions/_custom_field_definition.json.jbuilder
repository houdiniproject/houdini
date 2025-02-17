# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.call(custom_field_definition, :id, :name, :deleted)

json.object "custom_field_definition"

json.url api_nonprofit_custom_field_definition_url(custom_field_definition.nonprofit, custom_field_definition)

json.nonprofit custom_field_definition.nonprofit.id
