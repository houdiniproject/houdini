# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe "Direct routes", type: :routing do
  describe "#nonprofit_locatable" do
    it 'routes to a nonprofit' do
      nonprofit = create(:nonprofit_base)
      expect(get: nonprofit_locateable_path(nonprofit, only_path: true)).to route_to(
        controller: "nonprofits",
        action: "show", 
        state_code: nonprofit.state_code_slug,
        city: nonprofit.city_slug,
        name: nonprofit.slug
      )
    end
  end

  describe "#nonprofit_locatable_dashboard" do
    it 'routes to a nonprofit dashboard' do
      nonprofit = create(:nonprofit_base)
      expect(get: nonprofit_locateable_dashboard_path(nonprofit, only_path: true)).to route_to(
        controller: "nonprofits",
        action: "dashboard", 
        state_code: nonprofit.state_code_slug,
        city: nonprofit.city_slug,
        name: nonprofit.slug
      )
    end
  end
end