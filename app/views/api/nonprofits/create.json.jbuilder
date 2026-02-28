# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
json.id @nonprofit.id
json.name @nonprofit.name
json.city @nonprofit.city
json.state_code @nonprofit.state_code
json.zip_code @nonprofit.zip_code
json.state_code_slug @nonprofit.state_code_slug
json.city_slug @nonprofit.city_slug
json.slug @nonprofit.slug
json.email @nonprofit.email
json.website @nonprofit.website
json.phone @nonprofit.phone

json.urls do
  json.plain_url nonprofit_url(@nonprofit)
  json.slug_url nonprofit_slug_url(@nonprofit)
end
