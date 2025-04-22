# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe CreatePeerToPeerCampaign do
  describe ".create" do
    let!(:profile) { force_create(:profile, user: force_create(:user)) }
    let!(:parent_campaign) { force_create(:campaign, name: "Parent campaign", nonprofit: force_create(:nm_justice)) }

    context "when successful" do
      around do |example|
        Timecop.freeze(2020, 4, 5) do
          example.run
        end
      end

      it "returns a campaign" do
        campaign_params = {name: "Child campaign", parent_campaign_id: parent_campaign.id,
                           goal_amount_dollars: "1000"}

        result = described_class.create(campaign_params, profile.id)

        expect(result).to be_a Campaign
      end

      describe "returns created peer-to-peer campaign" do
        subject { described_class.create(campaign_params, profile.id) }

        let(:campaign_params) do
          {name: "Child campaign", parent_campaign_id: parent_campaign.id,
           goal_amount_dollars: "1000"}
        end

        it { is_expected.to be_a(Campaign) }

        it {
          is_expected.to have_attributes(
            errors: be_empty,
            parent_campaign: parent_campaign,
            created_at: Time.current
          )
        }
      end

      describe "assigns proper slug" do
        subject { described_class.create(campaign_params, profile.id) }

        let(:campaign_params) do
          {name: "Child campaign", parent_campaign_id: parent_campaign.id,
           goal_amount_dollars: "1000"}
        end

        it {
          is_expected.to have_attributes(
            errors: be_empty,
            slug: "child-campaign_000"
          )
        }
      end

      it "saves campaign" do
        campaign_params = {name: "Child campaign", parent_campaign_id: parent_campaign.id,
                           goal_amount_dollars: "1000"}
        expect { described_class.create(campaign_params, profile.id) }.to change(Campaign, :count).by 1
      end
    end

    context "when on failure" do
      it "returns an error if parent campaign can't be found" do
        campaign_params = {}
        expect do
          described_class.create(campaign_params, profile.id)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "returns a list of error messages for attribute validation" do # rubocop:disable RSpec/MultipleExpectations
        campaign_params = {parent_campaign_id: parent_campaign.id}
        expect { described_class.create(campaign_params, profile.id) }.to(
          raise_error do |error|
            expect(error).to be_an_instance_of(ActiveRecord::RecordInvalid)
            expect(error.record).to be_a Campaign
            expect(error.record.errors.empty?).to be false
            expect(error.record.errors["goal_amount"]).to match [
              "can't be blank", "is not a number"
            ]
          end
        )
      end

      RSpec::Matchers.define_negated_matcher :not_change, :change

      it "doesn't save campaign" do
        campaign_params = {}
        Timecop.freeze(2020, 4, 5) do
          expect do
            described_class.create(
              campaign_params,
              profile.id
            )
          end.to raise_error(ActiveRecord::RecordNotFound).and not_change(Campaign, :count)
        end
      end
    end
  end
end
