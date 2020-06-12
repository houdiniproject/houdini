# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
json.extract! nonprofit, :id, :name, #basics
                :brand_color, :brand_font, :tagline, #brand
                :zip_code, :state_code, :city, :latitude, :longitude, #location
                :slug, :state_code_slug, :city_slug, #slugs
                :no_anon #options
json.url nonprofit_path(nonprofit)
json.logo do
    json.normal url_for(nonprofit.logo_by_size(:normal))
end