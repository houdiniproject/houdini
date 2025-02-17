# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Api::NonprofitsHelper
  def nonprofit_slug_url(nonprofit)
    nonprofit_location_url city: nonprofit.city_slug, state_code: nonprofit.state_code_slug, name: nonprofit.slug
  end

  def nonprofit_slug_path(nonprofit)
    nonprofit_location_path city: nonprofit.city_slug, state_code: nonprofit.state_code_slug, name: nonprofit.slug
  end
end
