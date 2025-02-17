# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe Api::TicketLevelsController do
  let(:event) { ticket_level_with_event_non_admin__order_3__not_deleted.event }
  let(:nonprofit) { event.nonprofit }
  let(:user) { create(:user) }

  let(:ticket_level_with_event_non_admin__order_3__not_deleted) do
    create(:ticket_level_with_event_non_admin__order_3__not_deleted)
  end

  before do
    ticket_level_with_event_non_admin__order_3__not_deleted
  end

  def index_base_path(nonprofit_id, event_id)
    "/api/nonprofits/#{nonprofit_id}/events/#{event_id}/ticket_levels"
  end

  def index_base_url(nonprofit_id, event_id)
    "http://www.example.com#{index_base_path(nonprofit_id, event_id)}"
  end

  describe "GET /:id" do
    let(:ticket_level) { ticket_level_with_event_non_admin__order_3__not_deleted }

    def base_path(nonprofit_id, event_id, ticket_level_id)
      index_base_path(nonprofit_id, event_id) + "/#{ticket_level_id}"
    end

    def base_url(nonprofit_id, event_id, ticket_level_id)
      "http://www.example.com#{base_path(nonprofit_id, event_id, ticket_level_id)}"
    end

    context "with nonprofit user" do
      subject do
        response.parsed_body
      end

      before do
        user.roles.create(name: "nonprofit_associate", host: nonprofit)
        sign_in user
        get base_path(
          nonprofit.id,
          event.id,
          ticket_level_with_event_non_admin__order_3__not_deleted.id
        )
      end

      it {
        expect(response).to have_http_status(:success)
      }

      include_context "json results for ticket_level_with_event_non_admin__order_3__not_deleted"
    end

    context "with event editor" do
      subject do
        response.parsed_body
      end

      before do
        user.roles.create(name: "event_editor", host: event)
        sign_in user
        get base_path(
          nonprofit.id,
          event.id,
          ticket_level_with_event_non_admin__order_3__not_deleted.id
        )
      end

      it {
        expect(response).to have_http_status(:success)
      }

      include_context "json results for ticket_level_with_event_non_admin__order_3__not_deleted"
    end

    context "with no user" do
      it "returns unauthorized" do
        get base_path(
          nonprofit.id,
          event.id,
          ticket_level_with_event_non_admin__order_3__not_deleted.id
        )
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /" do
    context "with nonprofit user" do
      subject(:json) do
        response.parsed_body
      end

      before do
        user.roles.create(name: "nonprofit_associate", host: nonprofit)
        sign_in user
        get index_base_path(nonprofit.id, event.id)
      end

      it {
        expect(response).to have_http_status(:success)
      }

      it {
        expect(json["data"].count).to eq 1
      }

      # lazy testing but it works.
      it { is_expected.to include("first_page" => true) }
      it { is_expected.to include("last_page" => true) }
      it { is_expected.to include("current_page" => 1) }
      it { is_expected.to include("requested_size" => 25) }
      it { is_expected.to include("total_count" => 1) }

      describe "for ticket_level_with_event_non_admin__order_3__not_deleted" do
        subject(:first) do
          json["data"][0]
        end

        def base_path(nonprofit_id, event_id, ticket_level_id)
          index_base_path(nonprofit_id, event_id) + "/#{ticket_level_id}"
        end

        let(:ticket_level) { ticket_level_with_event_non_admin__order_3__not_deleted }

        def base_url(nonprofit_id, event_id, ticket_level_id)
          "http://www.example.com#{base_path(nonprofit_id, event_id, ticket_level_id)}"
        end
        include_context "json results for ticket_level_with_event_non_admin__order_3__not_deleted"
      end
    end

    context "with event editor" do
      subject(:json) do
        response.parsed_body
      end

      before do
        user.roles.create(name: "event_editor", host: event)
        sign_in user
        get index_base_path(nonprofit.id, event.id)
      end

      it {
        expect(response).to have_http_status(:success)
      }

      it {
        expect(json["data"].count).to eq 1
      }

      # lazy testing but it works.
      it { is_expected.to include("first_page" => true) }
      it { is_expected.to include("last_page" => true) }
      it { is_expected.to include("current_page" => 1) }
      it { is_expected.to include("requested_size" => 25) }
      it { is_expected.to include("total_count" => 1) }

      describe "for ticket_level_with_event_non_admin__order_3__not_deleted" do
        subject(:first) do
          json["data"][0]
        end

        let(:ticket_level) { ticket_level_with_event_non_admin__order_3__not_deleted }

        def base_path(nonprofit_id, event_id, ticket_level_id)
          index_base_path(nonprofit_id, event_id) + "/#{ticket_level_id}"
        end

        def base_url(nonprofit_id, event_id, ticket_level_id)
          "http://www.example.com#{base_path(nonprofit_id, event_id, ticket_level_id)}"
        end

        include_context "json results for ticket_level_with_event_non_admin__order_3__not_deleted"
      end
    end

    context "with no user" do
      it "returns unauthorized" do
        get index_base_path(nonprofit.id, event.id)
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
