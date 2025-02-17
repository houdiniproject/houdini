# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.call(tag_definition, :id, :name, :deleted)

json.object "tag_definition"

json.url api_nonprofit_tag_definition_url(tag_definition.nonprofit, tag_definition)

json.nonprofit tag_definition.nonprofit.id
