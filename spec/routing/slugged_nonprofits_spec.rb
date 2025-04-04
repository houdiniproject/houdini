# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe "Slugged routes", type: :routing do
  before(:each) do
    # this makes sure that our routes have a default host which is what they need for testing
    allow(Rails.application.routes).to receive(:default_url_options).and_return(ApplicationMailer.default_url_options)
  end

  describe "slugged_nonprofit" do
    it 'routes to a nonprofit' do
      nonprofit = create(:nonprofit_base)
      expect(get: slugged_nonprofit_path(nonprofit)).to route_to(
        controller: "nonprofits",
        action: "show", 
        state_code: nonprofit.state_code_slug,
        city: nonprofit.city_slug,
        name: nonprofit.slug,
      )
    end

    it 'routes to a nonprofit and accepts params' do
      nonprofit = create(:nonprofit_base)
      expect(get: slugged_nonprofit_path(nonprofit, foo: 'bar')).to route_to(
        controller: "nonprofits",
        action: "show", 
        state_code: nonprofit.state_code_slug,
        city: nonprofit.city_slug,
        name: nonprofit.slug,
        foo: 'bar',
      )
    end
  end

  describe "slugged_nonprofit_dashboard" do
    it 'routes to a nonprofit dashboard' do
      nonprofit = create(:nonprofit_base)
      expect(get: slugged_nonprofit_dashboard_path(nonprofit)).to route_to(
        controller: "nonprofits",
        action: "dashboard", 
        state_code: nonprofit.state_code_slug,
        city: nonprofit.city_slug,
        name: nonprofit.slug,
      )
    end

    it 'routes to a nonprofit dashboard and accepts params' do
      nonprofit = create(:nonprofit_base)
      expect(get: slugged_nonprofit_dashboard_path(nonprofit, foo: 'bar')).to route_to(
        controller: "nonprofits",
        action: "dashboard", 
        state_code: nonprofit.state_code_slug,
        city: nonprofit.city_slug,
        name: nonprofit.slug,
        foo: 'bar',
      )
    end
  end
end
