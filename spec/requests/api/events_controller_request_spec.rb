# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.shared_examples "common event api result" do
  it {
    expect(response).to have_http_status(:success)
  }

  it {
    is_expected.to include("object" => "event")
  }

  it {
    is_expected.to include("id" => event.id)
  }

  it {
    is_expected.to include("name" => event.name)
  }

  it {
    is_expected.to include("nonprofit" => nonprofit.id)
  }

  it {
    is_expected.to include("url" => base_url(nonprofit.id, event.id))
  }
end

RSpec.describe Api::EventsController do
  let(:event) { create(:fv_poverty_fighting_event_with_nonprofit_and_profile) }
  let(:nonprofit) { event.nonprofit }
  let(:user) { create(:user) }

  before do
    event
    user.roles.create(name: "nonprofit_associate", host: nonprofit)
  end

  def base_path(nonprofit_id, event_id)
    "/api/nonprofits/#{nonprofit_id}/events/#{event_id}"
  end

  def base_url(nonprofit_id, event_id)
    "http://www.example.com#{base_path(nonprofit_id, event_id)}"
  end

  describe "GET /:id" do
    context "with nonprofit user" do
      subject do
        response.parsed_body
      end

      before do
        user.roles.create(name: "nonprofit_associate", host: nonprofit)
        sign_in user
        get base_url(nonprofit.id, event.id)
      end

      include_context "common event api result"
    end

    context "with event editor" do
      subject do
        response.parsed_body
      end

      before do
        user.roles.create(name: "event_editor", host: event)
        sign_in user
        get base_url(nonprofit.id, event.id)
      end

      include_context "common event api result"
    end

    context "with no user" do
      it "returns http unauthorized when not logged in" do
        get base_url(nonprofit.id, event.id)
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
