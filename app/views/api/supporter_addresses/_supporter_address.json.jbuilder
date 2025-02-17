# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.call(supporter_address, :id, :address, :city, :state_code, :country, :zip_code, :deleted)

json.object "supporter_address"

json.url api_nonprofit_supporter_supporter_address_url(supporter_address.nonprofit, supporter_address,
  supporter_address)

json.nonprofit supporter_address.nonprofit.id

json.supporter supporter_address.id
