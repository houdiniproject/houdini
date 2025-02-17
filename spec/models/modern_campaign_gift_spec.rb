# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe ModernCampaignGift, type: :model do
  include_context :shared_donation_charge_context
  # TODO Why are we manually setting everything here? It's not clear what order things should
  # go in for a transaction. Therefore, we don't assume the order for now and just make sure the
  # the output of to_builder is right
  let(:trx) { force_create(:transaction, supporter: supporter, amount: 400) }

  let(:campaign_gift_purchase) { trx.campaign_gift_purchases.create(campaign: campaign, amount: 400, campaign_gifts: [ModernCampaignGift.new(amount: 400, legacy_campaign_gift: lcg)]) }
  let(:lcg) {
    CampaignGift.create(
      donation: supporter.donations.create(amount: 400, campaign: campaign, nonprofit: nonprofit, supporter: supporter),
      campaign_gift_option: campaign_gift_option
    )
  }
  let(:campaign_gift_option) { create(:campaign_gift_option, amount_one_time: 400, campaign: campaign) }
  let(:campaign_gift) { campaign_gift_purchase.campaign_gifts.first }

  let(:campaign_builder_expanded) do
    {
      "id" => kind_of(Numeric),
      "name" => campaign.name,
      "object" => "campaign",
      "nonprofit" => nonprofit.id
    }
  end

  let(:cgo_builder_expanded) do
    {
      "id" => kind_of(Numeric),
      "name" => campaign_gift_option.name,
      "description" => campaign_gift_option.description,
      "hide_contributions" => campaign_gift_option.hide_contributions,
      "order" => campaign_gift_option.order,
      "to_ship" => campaign_gift_option.to_ship,
      "object" => "campaign_gift_option",
      "deleted" => false,
      "gift_option_amount" => [{
        "amount" => {
          "cents" => 400,
          "currency" => "usd"
        },
        "recurrence" => nil
      }],
      "campaign" => kind_of(Numeric),
      "nonprofit" => kind_of(Numeric)
    }
  end

  let(:np_builder_expanded) do
    {
      "id" => nonprofit.id,
      "name" => nonprofit.name,
      "object" => "nonprofit"
    }
  end

  let(:supporter_builder_expanded) do
    supporter_to_builder_base.merge({"name" => "Fake Supporter Name"})
  end

  let(:transaction_builder_expanded) do
    {
      "id" => match_houid("trx"),
      "object" => "transaction",
      "amount" => {
        "cents" => trx.amount,
        "currency" => "usd"
      },
      "created" => Time.current.to_i,
      "supporter" => kind_of(Numeric),
      "nonprofit" => kind_of(Numeric),
      "subtransaction" => nil,
      "payments" => [],
      "transaction_assignments" => [cgp_builder_to_id]
    }
  end

  let(:cgp_builder_to_id) do
    {
      "id" => match_houid("cgpur"),
      "object" => "campaign_gift_purchase",
      "type" => "trx_assignment"
    }
  end

  let(:cgp_builder_expanded) do
    {
      "id" => match_houid("cgpur"),
      "campaign" => kind_of(Numeric),
      "object" => "campaign_gift_purchase",
      "campaign_gifts" => [match_houid("cgift")],
      "amount" => {
        "cents" => trx.amount,
        "currency" => "usd"
      },
      "supporter" => kind_of(Numeric),
      "nonprofit" => kind_of(Numeric),
      "transaction" => match_houid("trx"),
      "deleted" => false,
      "type" => "trx_assignment"
    }
  end

  it "announces created properly when called" do
    allow(Houdini.event_publisher).to receive(:announce)
    expect(Houdini.event_publisher).to receive(:announce).with(:campaign_gift_created, {
      "id" => match_houid("objevt"),
      "object" => "object_event",
      "type" => "campaign_gift.created",
      "data" => {
        "object" => {
          "amount" => {
            "cents" => 400,
            "currency" => "usd"
          },
          "campaign" => campaign_builder_expanded,
          "campaign_gift_option" => cgo_builder_expanded,
          "campaign_gift_purchase" => cgp_builder_expanded,
          "deleted" => false,
          "id" => match_houid("cgift"),
          "nonprofit" => np_builder_expanded,
          "object" => "campaign_gift",
          "supporter" => supporter_builder_expanded,
          "transaction" => transaction_builder_expanded
        }
      }
    })

    campaign_gift.publish_created
  end

  it "announces updated properly when called" do
    allow(Houdini.event_publisher).to receive(:announce)
    expect(Houdini.event_publisher).to receive(:announce).with(:campaign_gift_updated, {
      "id" => match_houid("objevt"),
      "object" => "object_event",
      "type" => "campaign_gift.updated",
      "data" => {
        "object" => {
          "amount" => {
            "cents" => 400,
            "currency" => "usd"
          },
          "campaign" => campaign_builder_expanded,
          "campaign_gift_option" => cgo_builder_expanded,
          "campaign_gift_purchase" => cgp_builder_expanded,
          "deleted" => false,
          "id" => match_houid("cgift"),
          "nonprofit" => np_builder_expanded,
          "object" => "campaign_gift",
          "supporter" => supporter_builder_expanded,
          "transaction" => transaction_builder_expanded
        }
      }
    })

    campaign_gift.publish_updated
  end

  it "announces updated deleted properly when called" do
    allow(Houdini.event_publisher).to receive(:announce)
    expect(Houdini.event_publisher).to receive(:announce).with(:campaign_gift_deleted, {
      "id" => match_houid("objevt"),
      "object" => "object_event",
      "type" => "campaign_gift.deleted",
      "data" => {
        "object" => {
          "amount" => {
            "cents" => 400,
            "currency" => "usd"
          },
          "campaign" => campaign_builder_expanded,
          "campaign_gift_option" => cgo_builder_expanded,
          "campaign_gift_purchase" => cgp_builder_expanded,
          "deleted" => true,
          "id" => match_houid("cgift"),
          "nonprofit" => np_builder_expanded,
          "object" => "campaign_gift",
          "supporter" => supporter_builder_expanded,
          "transaction" => transaction_builder_expanded
        }
      }
    })

    campaign_gift.discard!
    campaign_gift.publish_deleted
  end
end
