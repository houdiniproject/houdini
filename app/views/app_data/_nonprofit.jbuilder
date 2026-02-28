# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

# described in app/javascript/legacy/app_data/Nonprofit.ts

json.extract! nonprofit, :id, :name, # basics
  :brand_color, :brand_font, :tagline, # brand
  :zip_code, :state_code, :city,
  :slug, :state_code_slug, :city_slug, # slugs
  :no_anon # options
json.url nonprofit_path(nonprofit)
json.logo do
  json.normal rails_storage_proxy_url(nonprofit.logo_by_size(:normal))
  json.small rails_storage_proxy_url(nonprofit.logo_by_size(:small))
end
