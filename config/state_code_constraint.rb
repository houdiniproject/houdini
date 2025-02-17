# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class StateCodeConstraint
  def matches?(request)
    ISO3166::Country[:US].subdivisions.has_key? request.params[:state_code].upcase
  end
end
