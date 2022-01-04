# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module NonprofitPath
  def self.show(np)
    return '/' unless np

    "/#{np.state_code_slug}/#{np.city_slug}/#{np.slug}"
  end

  def self.dashboard(np)
    "#{show(np)}/dashboard"
  end
end
