# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.call(supporter, :id, :name, :organization, :phone, :anonymous, :deleted)

json.object "supporter"

json.merged_into supporter.merged_into&.id

json.supporter_addresses [supporter.id]

json.url api_nonprofit_supporter_url(supporter.nonprofit, supporter)

json.nonprofit supporter.nonprofit.id
