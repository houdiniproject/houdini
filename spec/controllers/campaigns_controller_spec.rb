# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"
require "controllers/support/shared_user_context"

describe CampaignsController do
  describe "authorization" do
    include_context :shared_user_context
    describe "rejects unauthorized users" do
      describe "create" do
        include_context :open_to_confirmed_users,
          :post,
          :create,
          nonprofit_id: :__our_np,
          with_status: 200 # why? I don't know.
      end

      describe "name_and_id" do
        include_context :open_to_confirmed_users, :get, :name_and_id, nonprofit_id: :__our_np
      end

      describe "duplicate" do
        include_context :open_to_confirmed_users, :post, :duplicate, nonprofit_id: :__our_np, id: :__our_campaign
      end

      describe "update" do
        include_context :open_to_campaign_editor, :put, :update, nonprofit_id: :__our_np, id: :__our_campaign,
          with_status: 200
      end

      describe "soft_delete" do
        include_context :open_to_campaign_editor, :delete, :soft_delete, nonprofit_id: :__our_np, id: :__our_campaign
      end
    end

    describe "open to all" do
      describe "index" do
        include_context :open_to_all, :get, :index, nonprofit_id: :__our_np, without_json_view: true
      end

      describe "show" do
        include_context :open_to_all, :get, :show, nonprofit_id: :__our_np, id: :__our_campaign, without_json_view: true
      end

      describe "activities" do
        include_context :open_to_all, :get, :activities, nonprofit_id: :__our_np, id: :__our_campaign
      end

      describe "metrics" do
        include_context :open_to_all, :get, :metrics, nonprofit_id: :__our_np, id: :__our_campaign
      end

      describe "timeline" do
        include_context :open_to_all, :get, :timeline, nonprofit_id: :__our_np, id: :__our_campaign
      end

      describe "totals" do
        include_context :open_to_all, :get, :totals, nonprofit_id: :__our_np, id: :__our_campaign
      end

      describe "peer_to_peer" do
        include_context :open_to_all, :get, :peer_to_peer, nonprofit_id: :__our_np, without_json_view: true
      end
    end
  end

  describe "routes" do
    it {
      is_expected.to route(
        :get, "/nonprofits/5/campaigns/4"
      ).to(
        controller: "campaigns", action: "show", nonprofit_id: "5",
        id: "4"
      )
    }
  end

  describe "index" do
    render_views
    let(:nonprofit) { force_create(:nm_justice, published: true) }
    let(:campaign) { force_create(:campaign, nonprofit: nonprofit, name: "simplename", goal_amount: 444) }

    before do
      campaign
      get(:index, params: {nonprofit_id: nonprofit.id, format: :json})
    end

    it "has ok status" do
      expect(response).to have_http_status(:ok)
    end

    it "has correct items" do
      body = response.parsed_body
      expect(body).to eq(
        {
          data: [
            {
              id: campaign.id,
              name: "simplename",
              total_raised: 0,
              goal_amount: 444,
              url: "http://test.host/nm/albuquerque/new-mexico-equality/campaigns/slug_#{campaign.id}"
            }
          ]
        }.with_indifferent_access
      )
    end
  end
end
