# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe Api::CampaignGiftOptionsController do
  let(:campaign) { campaign_gift_option_with_campaign_with_one_time_amount.campaign }
  let(:nonprofit) { campaign.nonprofit }
  let(:user) { create(:user) }

  let(:campaign_gift_option_with_campaign_with_one_time_amount) do
    create(:campaign_gift_option_with_campaign_with_one_time_amount)
  end
  let(:campaign_gift_option_with_campaign_with_recurring_amount) do
    create(:campaign_gift_option_with_campaign_with_recurring_amount,
      campaign: campaign_gift_option_with_campaign_with_one_time_amount.campaign)
  end
  let(:campaign_gift_option_with_campaign_with_both_one_time_and_recurring_amount) do
    create(:campaign_gift_option_with_campaign_with_both_one_time_and_recurring_amount,
      campaign: campaign_gift_option_with_campaign_with_one_time_amount.campaign)
  end

  before do
    campaign_gift_option_with_campaign_with_one_time_amount
    campaign_gift_option_with_campaign_with_recurring_amount
    campaign_gift_option_with_campaign_with_both_one_time_and_recurring_amount
  end

  def base_path(nonprofit_id, campaign_id)
    "/api/nonprofits/#{nonprofit_id}/campaigns/#{campaign_id}/campaign_gift_options"
  end

  def base_url(nonprofit_id, campaign_id)
    "http://www.example.com#{base_path(nonprofit_id, campaign_id)}"
  end

  describe "GET /:id" do
    context "with nonprofit user" do
      subject do
        response.parsed_body
      end

      before do
        user.roles.create(name: "nonprofit_associate", host: nonprofit)
        sign_in user
        get base_path(
          nonprofit.id,
          campaign.id
        ) +
          "/#{campaign_gift_option_with_campaign_with_one_time_amount.id}"
      end

      it {
        expect(response).to have_http_status(:success)
      }

      it {
        is_expected.to include("object" => "campaign_gift_option")
      }

      it {
        is_expected.to include("id" => campaign_gift_option_with_campaign_with_one_time_amount.id)
      }

      it {
        is_expected.to include("name" => "has one time amount")
      }

      it {
        is_expected.to include("nonprofit" => nonprofit.id)
      }

      it {
        is_expected.to include("deleted" => false)
      }

      it {
        is_expected.to include("campaign" => campaign.id)
      }

      it {
        is_expected.to include("description" => "one time description")
      }

      it {
        is_expected.to include("hide_contributions" => false)
      }

      it {
        is_expected.to include("order" => nil)
      }

      it {
        is_expected.to include("to_ship" => false)
      }

      it {
        is_expected.to include("quantity" => nil)
      }

      it {
        is_expected.to include("gift_option_amount" => match_array(
          [{
            "amount" => {"cents" => 200, "currency" => nonprofit.currency},
            "recurrence" => nil
          }]
        ))
      }

      it {
        is_expected.to include("url" =>
          base_url(
            nonprofit.id,
            campaign.id
          ) + "/#{campaign_gift_option_with_campaign_with_one_time_amount.id}")
      }
    end

    context "with campaign editor" do
      subject do
        response.parsed_body
      end

      before do
        user.roles.create(name: "campaign_editor", host: campaign)
        sign_in user
        get base_path(
          nonprofit.id,
          campaign.id
        ) + "/#{campaign_gift_option_with_campaign_with_one_time_amount.id}"
      end

      it {
        is_expected.to include("object" => "campaign_gift_option")
      }

      it {
        is_expected.to include("id" => campaign_gift_option_with_campaign_with_one_time_amount.id)
      }

      it {
        is_expected.to include("name" => "has one time amount")
      }

      it {
        is_expected.to include("nonprofit" => nonprofit.id)
      }

      it {
        is_expected.to include("deleted" => false)
      }

      it {
        is_expected.to include("campaign" => campaign.id)
      }

      it {
        is_expected.to include("description" => "one time description")
      }

      it {
        is_expected.to include("hide_contributions" => false)
      }

      it {
        is_expected.to include("order" => nil)
      }

      it {
        is_expected.to include("to_ship" => false)
      }

      it {
        is_expected.to include("quantity" => nil)
      }

      it {
        is_expected.to include("gift_option_amount" => match_array(
          [{
            "amount" => {"cents" => 200, "currency" => nonprofit.currency},
            "recurrence" => nil
          }]
        ))
      }

      it {
        is_expected.to include("url" =>
        base_url(
          nonprofit.id,
          campaign.id
        ) + "/#{campaign_gift_option_with_campaign_with_one_time_amount.id}")
      }
    end

    context "with no user" do
      it "returns unauthorized" do
        get base_path(
          nonprofit.id,
          campaign.id
        ) + "/#{campaign_gift_option_with_campaign_with_one_time_amount.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /" do
    shared_context "when campaign_gift_option_with_campaign_with_one_time_amount" do
      let(:campaign) { campaign_gift_option.campaign }
      let(:nonprofit) { campaign_gift_option.nonprofit }

      it {
        is_expected.to include("object" => "campaign_gift_option")
      }

      it {
        is_expected.to include("id" => campaign_gift_option.id)
      }

      it {
        is_expected.to include("name" => "has one time amount")
      }

      it {
        is_expected.to include("nonprofit" => nonprofit.id)
      }

      it {
        is_expected.to include("deleted" => false)
      }

      it {
        is_expected.to include("campaign" => campaign.id)
      }

      it {
        is_expected.to include("description" => "one time description")
      }

      it {
        is_expected.to include("hide_contributions" => false)
      }

      it {
        is_expected.to include("order" => nil)
      }

      it {
        is_expected.to include("to_ship" => false)
      }

      it {
        is_expected.to include("quantity" => nil)
      }

      it {
        is_expected.to include("gift_option_amount" => match_array(
          [{
            "amount" => {"cents" => 200, "currency" => nonprofit.currency},
            "recurrence" => nil
          }]
        ))
      }

      it {
        is_expected.to include("url" =>
        base_url(
          nonprofit.id,
          campaign.id
        ) + "/#{campaign_gift_option.id}")
      }
    end

    shared_context "when campaign_gift_option_with_campaign_with_recurring_amount" do
      let(:campaign) { campaign_gift_option.campaign }
      let(:nonprofit) { campaign_gift_option.nonprofit }

      it {
        is_expected.to include("object" => "campaign_gift_option")
      }

      it {
        is_expected.to include("id" => campaign_gift_option.id)
      }

      it {
        is_expected.to include("name" => "has recurring amount")
      }

      it {
        is_expected.to include("nonprofit" => nonprofit.id)
      }

      it {
        is_expected.to include("deleted" => false)
      }

      it {
        is_expected.to include("campaign" => campaign.id)
      }

      it {
        is_expected.to include("description" => "a recurring description!")
      }

      it {
        is_expected.to include("hide_contributions" => false)
      }

      it {
        is_expected.to include("order" => nil)
      }

      it {
        is_expected.to include("to_ship" => false)
      }

      it {
        is_expected.to include("quantity" => 4)
      }

      it {
        is_expected.to include("gift_option_amount" => match_array(
          [{
            "amount" => {"cents" => 400, "currency" => nonprofit.currency},
            "recurrence" => {"interval" => 1, "type" => "monthly"}
          }]
        ))
      }

      it {
        is_expected.to include("url" =>
            a_string_matching(
              base_url(
                nonprofit.id,
                campaign.id
              ) + "/#{campaign_gift_option.id}"
            ))
      }
    end

    shared_context "when campaign_gift_option_with_campaign_with_both_one_time_and_recurring_amount" do
      let(:campaign) { campaign_gift_option.campaign }
      let(:nonprofit) { campaign_gift_option.nonprofit }

      it {
        is_expected.to include("object" => "campaign_gift_option")
      }

      it {
        is_expected.to include("id" => campaign_gift_option.id)
      }

      it {
        is_expected.to include("name" => "has both one time and recurring amount")
      }

      it {
        is_expected.to include("nonprofit" => nonprofit.id)
      }

      it {
        is_expected.to include("deleted" => false)
      }

      it {
        is_expected.to include("campaign" => campaign.id)
      }

      it {
        is_expected.to include("description" => "one time AND recurring")
      }

      it {
        is_expected.to include("hide_contributions" => true)
      }

      it {
        is_expected.to include("order" => 5)
      }

      it {
        is_expected.to include("to_ship" => true)
      }

      it {
        is_expected.to include("quantity" => 50)
      }

      it {
        is_expected.to include("gift_option_amount" => match_array(
          [
            {
              "amount" => {"cents" => 500, "currency" => nonprofit.currency},
              "recurrence" => {"interval" => 1, "type" => "monthly"}
            },
            {
              "amount" => {"cents" => 300, "currency" => nonprofit.currency},
              "recurrence" => nil
            }

          ]
        ))
      }

      it {
        is_expected.to include("url" =>
          base_url(
            nonprofit.id,
            campaign.id
          ) + "/#{campaign_gift_option.id}")
      }
    end

    context "with nonprofit user" do
      subject(:json) do
        response.parsed_body
      end

      before do
        user.roles.create(name: "nonprofit_associate", host: nonprofit)
        sign_in user
        get base_path(nonprofit.id, campaign.id)
      end

      it {
        expect(response).to have_http_status(:success)
      }

      it {
        expect(json["data"].count).to eq 3
      }

      it { is_expected.to include("first_page" => true) }
      it { is_expected.to include("last_page" => true) }
      it { is_expected.to include("current_page" => 1) }
      it { is_expected.to include("requested_size" => 25) }
      it { is_expected.to include("total_count" => 3) }

      describe "for campaign_gift_option_with_campaign_with_one_time_amount" do
        subject(:first) do
          json["data"][2]
        end

        let(:campaign_gift_option) { campaign_gift_option_with_campaign_with_one_time_amount }

        include_context "when campaign_gift_option_with_campaign_with_one_time_amount"
      end

      describe "for campaign_gift_option_with_campaign_with_recurring_amount" do
        subject(:second) do
          json["data"][1]
        end

        let(:campaign_gift_option) { campaign_gift_option_with_campaign_with_recurring_amount }

        include_context "when campaign_gift_option_with_campaign_with_recurring_amount"
      end

      describe "for campaign_gift_option_with_campaign_with_both_one_time_and_recurring_amount" do
        subject(:third) do
          json["data"][0]
        end

        let(:campaign_gift_option) { campaign_gift_option_with_campaign_with_both_one_time_and_recurring_amount }

        include_context "when campaign_gift_option_with_campaign_with_both_one_time_and_recurring_amount"
      end
    end

    context "with campaign editor" do
      subject(:json) do
        response.parsed_body
      end

      before do
        user.roles.create(name: "campaign_editor", host: campaign)
        sign_in user
        get base_path(nonprofit.id, campaign.id)
      end

      it {
        expect(response).to have_http_status(:success)
      }

      it {
        expect(json["data"].count).to eq 3
      }

      it { is_expected.to include("first_page" => true) }
      it { is_expected.to include("last_page" => true) }
      it { is_expected.to include("current_page" => 1) }
      it { is_expected.to include("requested_size" => 25) }
      it { is_expected.to include("total_count" => 3) }

      describe "for campaign_gift_option_with_campaign_with_one_time_amount" do
        subject(:first) do
          json["data"][2]
        end

        let(:campaign_gift_option) { campaign_gift_option_with_campaign_with_one_time_amount }

        include_context "when campaign_gift_option_with_campaign_with_one_time_amount"
      end

      describe "for campaign_gift_option_with_campaign_with_recurring_amount" do
        subject(:second) do
          json["data"][1]
        end

        let(:campaign_gift_option) { campaign_gift_option_with_campaign_with_recurring_amount }

        include_context "when campaign_gift_option_with_campaign_with_recurring_amount"
      end

      describe "for campaign_gift_option_with_campaign_with_both_one_time_and_recurring_amount" do
        subject(:third) do
          json["data"][0]
        end

        let(:campaign_gift_option) { campaign_gift_option_with_campaign_with_both_one_time_and_recurring_amount }

        include_context "when campaign_gift_option_with_campaign_with_both_one_time_and_recurring_amount"
      end
    end

    context "with no user" do
      it "returns unauthorized" do
        get base_path(nonprofit.id, campaign.id)
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
