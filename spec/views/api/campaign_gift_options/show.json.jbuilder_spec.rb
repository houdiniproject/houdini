# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe "/api/campaign_gift_options/show.json.jbuilder" do
  def base_path(nonprofit_id, campaign_id, campaign_gift_option_id)
    "/api/nonprofits/#{nonprofit_id}/campaigns/#{campaign_id}/campaign_gift_options/#{campaign_gift_option_id}"
  end

  def base_url(nonprofit_id, campaign_id, campaign_gift_option_id)
    "http://test.host#{base_path(nonprofit_id, campaign_id, campaign_gift_option_id)}"
  end

  context "when campaign gift option only has one time amount" do
    subject(:json) do
      view.lookup_context.prefixes = view.lookup_context.prefixes.drop(2)
      assign(:campaign_gift_option, campaign_gift_option)
      render
      JSON.parse(rendered)
    end

    let(:campaign) { campaign_gift_option.campaign }
    let(:nonprofit) { campaign_gift_option.nonprofit }

    let(:campaign_gift_option) { create(:campaign_gift_option_with_campaign_with_one_time_amount) }

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
      base_url(nonprofit.id, campaign.id, campaign_gift_option.id))
    }
  end

  context "when campaign gift option only has recurring amount" do
    subject(:json) do
      view.lookup_context.prefixes = view.lookup_context.prefixes.drop(2)
      assign(:campaign_gift_option, campaign_gift_option)
      render
      JSON.parse(rendered)
    end

    let(:campaign) { campaign_gift_option.campaign }
    let(:nonprofit) { campaign_gift_option.nonprofit }

    let(:campaign_gift_option) { create(:campaign_gift_option_with_campaign_with_recurring_amount) }

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
      base_url(nonprofit.id, campaign.id, campaign_gift_option.id))
    }
  end

  context "when campaign gift option both one time and recurring amount" do
    subject(:json) do
      view.lookup_context.prefixes = view.lookup_context.prefixes.drop(2)
      assign(:campaign_gift_option, campaign_gift_option)
      render
      JSON.parse(rendered)
    end

    let(:campaign) { campaign_gift_option.campaign }
    let(:nonprofit) { campaign_gift_option.nonprofit }

    let(:campaign_gift_option) { create(:campaign_gift_option_with_campaign_with_both_one_time_and_recurring_amount) }

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
      base_url(nonprofit.id, campaign.id, campaign_gift_option.id))
    }
  end
end
