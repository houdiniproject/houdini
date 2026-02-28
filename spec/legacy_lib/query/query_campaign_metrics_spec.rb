# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe QueryCampaignMetrics do
  describe "calculates your metrics plus children" do
    let(:nonprofit) { force_create(:nm_justice) }
    let(:campaign) { force_create(:campaign, nonprofit: nonprofit, show_total_count: false, show_total_raised: false, goal_amount: 16_000) }
    let(:campaign_child) { force_create(:campaign, nonprofit: nonprofit, parent_campaign: campaign, show_total_count: true, show_total_raised: true, goal_amount: 8000) }

    let(:campaign_child_2) { force_create(:campaign, nonprofit: nonprofit, parent_campaign: campaign, show_total_count: true, show_total_raised: true, goal_amount: 4000) }

    let(:donation) { force_create(:donation, campaign: campaign, amount: 1000) }
    let(:payment) { force_create(:payment, donation: donation, gross_amount: 1000) }

    let(:donation2) { force_create(:donation, campaign: campaign, amount: 2000) }
    let(:payment2) { force_create(:payment, donation: donation2, gross_amount: 2000) }

    let(:donation3) { force_create(:donation, campaign: campaign_child, amount: 2000) }
    let(:payment3) { force_create(:payment, donation: donation3, gross_amount: 4000, kind: "RecurringPayment") }
    let(:payment3_1) { force_create(:payment, donation: donation3, gross_amount: 2000, kind: "RecurringPayment") }

    let(:donation4) { force_create(:donation, campaign: campaign_child_2, amount: 8000) }
    let(:payment4) { force_create(:payment, donation: donation4, gross_amount: 8000) }

    let(:payments) do
      payment
      payment2
      payment3
      payment3_1
      payment4
    end

    let(:campaign_metric) do
      payments
      QueryCampaignMetrics.on_donations(campaign.id)
    end

    let(:campaign_child_metric) do
      payments
      QueryCampaignMetrics.on_donations(campaign_child.id)
    end

    let(:campaign_child_2_metric) do
      payments
      QueryCampaignMetrics.on_donations(campaign_child_2.id)
    end

    it "campaign metric is valid" do
      expect(campaign_metric["supporters_count"]).to eq 4
      expect(campaign_metric["total_raised"]).to eq 15_000
      expect(campaign_metric["goal_amount"]).to eq 16_000
      expect(campaign_metric["show_total_count"]).to eq false
      expect(campaign_metric["show_total_raised"]).to eq false
    end

    it "campaign child metric is valid" do
      expect(campaign_child_metric["supporters_count"]).to eq 1
      expect(campaign_child_metric["total_raised"]).to eq 4000
      expect(campaign_child_metric["goal_amount"]).to eq 8000
      expect(campaign_child_metric["show_total_count"]).to eq true
      expect(campaign_child_metric["show_total_raised"]).to eq true
    end

    it "campaign child 2metric is valid" do
      expect(campaign_child_2_metric["supporters_count"]).to eq 1
      expect(campaign_child_2_metric["total_raised"]).to eq 8000
      expect(campaign_child_2_metric["goal_amount"]).to eq 4000
      expect(campaign_child_2_metric["show_total_count"]).to eq true
      expect(campaign_child_2_metric["show_total_raised"]).to eq true
    end
  end
end
