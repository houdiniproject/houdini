# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe ApiNew::ObjectEventsController, type: :request do
  let(:user) { create(:user) }
  let(:simple_object_with_parent) { create(:simple_object_with_parent) }
  before(:each) {
    simple_object_with_parent.publish_created
    simple_object_with_parent.publish_updated
  }

  def index_base_path(nonprofit_id)
    "/api_new/nonprofits/#{nonprofit_id}/object_events"
  end

  def index_base_url(nonprofit_id, _event_id)
    "http://www.example.com#{index_base_path(nonprofit_id)}"
  end

  let(:nonprofit) { simple_object_with_parent.nonprofit }

  describe "GET /" do
    context "with nonprofit user" do
      subject(:json) do
        JSON.parse(response.body)
      end

      before(:each) do
        user.roles.create(name: "nonprofit_associate", host: nonprofit)
        sign_in user
      end

      context "empty query" do
        before(:each) do
          get index_base_path(nonprofit.houid)
        end

        it {
          expect(json["total_count"]).to eq 2
        }
      end

      context "with event_entity" do
        context "and entity doesnt exist" do
          before(:each) do
            get index_base_path(nonprofit.houid), params: {event_entity: "fake_entity"}
          end

          it {
            expect(json["total_count"]).to eq 0
          }
        end

        context "and entity does exist" do
          before(:each) do
            get index_base_path(nonprofit.houid), params: {event_entity: simple_object_with_parent.houid}
          end

          it {
            expect(json["total_count"]).to eq 2
          }
        end
      end

      context "with event_types" do
        context "and event_types doesnt exist" do
          before(:each) do
            get index_base_path(nonprofit.houid), params: {event_types: ["soennoet.come"]}
          end

          it {
            expect(json["total_count"]).to eq 0
          }
        end

        context "and event_types does exist" do
          before(:each) do
            get index_base_path(nonprofit.houid), params: {event_types: ["simple_object.created"]}
          end

          it {
            expect(json["total_count"]).to eq 1
          }
        end

        context "and multiple event_types do exist" do
          before(:each) do
            get index_base_path(nonprofit.houid), params: {event_entity: ["simple_object.created", "simple_object.updated"]}
          end

          it {
            expect(json["total_count"]).to eq 2
          }
        end
      end
    end

    context "with no user" do
      it "returns unauthorized" do
        get index_base_path(nonprofit.houid)
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
