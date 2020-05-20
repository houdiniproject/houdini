# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe CreatePeerToPeerCampaign do
  describe '.create' do
    let!(:profile) { force_create(:profile, user: force_create(:user)) }
    let!(:parent_campaign) { force_create(:campaign, name: 'Parent campaign', nonprofit: force_create(:nm_justice)) }

    context 'on success' do
      it 'returns a hash' do
        campaign_params = { name: 'Child campaign', parent_campaign_id: parent_campaign.id, goal_amount_dollars: '1000' }
        Timecop.freeze(2020, 4, 5) do
          result = CreatePeerToPeerCampaign.create(campaign_params, profile.id)

          expect(result).to be_kind_of Hash
        end
      end

      it 'returns created peer-to-peer campaign' do
        campaign_params = { name: 'Child campaign', parent_campaign_id: parent_campaign.id, goal_amount_dollars: '1000' }
        Timecop.freeze(2020, 4, 5) do
          result = CreatePeerToPeerCampaign.create(campaign_params, profile.id)

          expect(result).not_to include 'errors'
          expect(result['parent_campaign_id']).to eq parent_campaign.id
          expect(result['created_at']).to eq 'Sun, 05 Apr 2020 00:00:00 UTC +00:00'
        end
      end

      it 'assigns proper slug' do
        campaign_params = { name: 'Child campaign', parent_campaign_id: parent_campaign.id, goal_amount_dollars: '1000' }
        Timecop.freeze(2020, 4, 5) do
          result = CreatePeerToPeerCampaign.create(campaign_params, profile.id)

          expect(result).not_to include 'errors'
          expect(result['slug']).to eq 'child-campaign_000'
        end
      end

      it 'saves campaign' do
        campaign_params = { name: 'Child campaign', parent_campaign_id: parent_campaign.id, goal_amount_dollars: '1000' }
        Timecop.freeze(2020, 4, 5) do
          expect { CreatePeerToPeerCampaign.create(campaign_params, profile.id) }.to change(Campaign, :count).by 1
        end
      end
    end

    context 'on failure' do
      it "returns an error if parent campaign can't be found" do
        campaign_params = {}
        Timecop.freeze(2020, 4, 5) do
          result = CreatePeerToPeerCampaign.create(campaign_params, profile.id)

          expect(result).to be_kind_of Hash
          expect(result['errors']['parent_campaign_id']).to eq 'not found'
        end
      end

      it 'returns a list of error messages for attribute validation' do
        campaign_params = { parent_campaign_id: parent_campaign.id }
        Timecop.freeze(2020, 4, 5) do
          result = CreatePeerToPeerCampaign.create(campaign_params, profile.id)

          expect(result).to be_kind_of Hash
          expect(result).to include 'errors'
          expect(result['errors']['goal_amount']).to match ["can't be blank", 'is not a number']
        end
      end

      it "doesn't save campaign" do
        campaign_params = {}
        Timecop.freeze(2020, 4, 5) do
          expect { CreatePeerToPeerCampaign.create(campaign_params, profile.id) }.not_to change(Campaign, :count)
        end
      end
    end
  end
end
