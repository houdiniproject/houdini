# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe 'Routing by state code', type: :routing do
    it 'routes by state-codes for lower case' do
        expect(post: "/wi/appleton/name").to route_to(
            controller: 'nonprofits',
            action: "show",
            state_code: "wi",
            city: "appleton",
            name: "name"
        )
    end

    it 'fails to route for an incorrect two letter state' do
        expect(post: "/us/appleton/name").to_not be_routable
    end

    it 'it fails to route if a valid state code is in the middle of the state_code' do
        expect(get: '/hoho/cleveland/interesting-name').to_not be_routable
    end
end