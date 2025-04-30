# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe EventsController, type: :request do
  def event_setup
    nonprofit = create(:nonprofit_base)
    OpenStruct.new(
      deleted: create(:event_base, nonprofit: nonprofit, deleted: true),
      last: create(:event_base, nonprofit: nonprofit, name: "Last event"),
      first: create(:event_base, nonprofit: nonprofit, name: "First event"),
      nonprofit: nonprofit
    )
  end

  def login_as_associate(nonprofit)
    user = create(:user_base, roles: [build(:role_base, name: "nonprofit_associate", host: nonprofit)])
    sign_in user
  end

  it "contains the events in order from first, to last with no deleted events" do
    Event.any_instance.stub(:geocode).and_return([1, 1]) # otherwise the geocode call fails
    events = event_setup

    login_as_associate(events.nonprofit)

    get "/nonprofits/#{events.nonprofit.id}/events/name_and_id"

    result = JSON.parse(response.body)

    expect(result).to include_json([
      {name: events.first.name, id: events.first.id},
      {name: events.last.name, id: events.last.id}
    ])
  end
end
